require File.join(File.dirname(__FILE__), "..", "spec_helper")

class Turtle < Erector::Widget
  cache_with :name
  
  def content
    div "Cool stuff below"
    widget NinjaTurtle, :name => @name, :weapon => @weapon, :master => @master
  end
end

class Master
  def initialize(name)
    @name = name
  end
  
  def name
    @name
  end
  
  def to_param
    @name
  end
end

class Weapon
  def initialize(name)
    @name = name
  end
  
  def name
    @name
  end
  
  def to_param
    @name
  end
end

class NinjaTurtle < Turtle
  cache_with :weapon, :master => [:to_param, lambda {|m| m.name }]
  cache_for 25.years
  
  def content
    span "Weapon: #{@weapon}"
    span "Cached at: #{Time.now.to_s(:db)}"
  end
end

class InterpolatedTurtle < Turtle
  def content
    div "Cool stuff below"
    widget InterpolatedNinjaTurtle, :name => @name, :weapon => @weapon, :master => @master, :pizzas_eaten => @pizzas_eaten
  end
end

class InterpolatedNinjaTurtle < NinjaTurtle
  cache_with :weapon, :master => lambda {|m| m.name }
  cache_for 25.years
  interpolate "PIZZAS_EATEN" => :pizzas_eaten
  
  def content
    span "Weapon: #{@weapon}"
    span "Cached at: #{Time.now.to_s(:db)}"
    span "Eaten: PIZZAS_EATEN pizzas"
  end
end


describe ErectorCache::Widget do
  before do
    @splinter = Master.new("Splinter")
  end
  
  describe "ClassMethods" do
    describe ".cache_with" do
      it "sets the attributes to cache instances of this widget with" do
        Turtle.key_components.should == [:name]
      end

      it "inherits parent classes cache key components" do
        component_parts = NinjaTurtle.key_components.map{|c| c.is_a?(Hash) ? c.keys.first : c}
        component_parts.should == [:name, :weapon, :master]
      end
    end
    
    describe ".expire!" do
      it "expires the cache" do
        render_template do |controller|
          controller.render_widget Turtle, :name => "Leonardo", :weapon => "Katanas", :master => @splinter
        end
        expected_cached_at_time = @output.match(/Cached at: (.*)</)[1]

        sleep 1
         
        render_template do |controller|
          controller.render_widget Turtle, :name => "Leonardo", :weapon => "Katanas", :master => @splinter, :slogan => "Turtle Power!"
        end
        @output.should include expected_cached_at_time
        
        NinjaTurtle.expire!(:weapon => "Katanas")

        sleep 1
        
        render_template do |controller|
          controller.render_widget Turtle, :name => "Leonardo", :weapon => "Katanas", :master => @splinter
        end
        @output.should_not include expected_cached_at_time
      end
      
      it "expires based on cache key component that is a proc" do
        @he_man = Master.new("He-man")
        render_template do |controller|
          controller.render_widget Turtle, :name => "Leonardo", :weapon => "Katanas", :master => @splinter
        end
        
        render_template do |controller|
          controller.render_widget Turtle, :name => "Myrtle", :weapon => "Shell", :master => @he_man
        end
        
        Lawnchair.redis.keys("*Splinter*").should_not be_blank
        Lawnchair.redis.keys("*He-man*").should_not be_blank
        NinjaTurtle.expire!(:master => @splinter)
        
        Lawnchair.redis.keys("*Splinter*").should be_blank
        Lawnchair.redis.keys("*He-man*").should_not be_blank
      end
      
      it "expires based on regular object with to_param" do
        @he_man = Master.new("He-man")
        @shell = Weapon.new("Shell")
        
        render_template do |controller|
          controller.render_widget Turtle, :name => "Leonardo", :weapon => Weapon.new("Katanas"), :master => @splinter
        end
        
        render_template do |controller|
          controller.render_widget Turtle, :name => "Myrtle", :weapon => @shell, :master => @he_man
        end
        
        Lawnchair.redis.keys("*Shell*").should_not be_blank
        Lawnchair.redis.keys("*Katanas*").should_not be_blank

        NinjaTurtle.expire!(:weapon => @shell)
        
        Lawnchair.redis.keys("*Shell*").should be_blank
        Lawnchair.redis.keys("*Katanas*").should_not be_blank
      end
    end
    
    describe ".cache_for" do
      it "sets appropriate ttl" do
        Turtle.expire_in.should == 25.years
      end
    end
  end
  
  describe "InstanceMethods" do
    describe "#cache_key" do
      it "builds a simple cache key for an instance properly" do
        widget = Turtle.new(:name => "Yertle")
        widget.cache_key.should == "Turtle:name:Yertle"
      end
      
      it "builds a complex cache key" do
        widget = NinjaTurtle.new(:name => "Leonardo", :master => @splinter, :weapon => "Dual Katanas")
        widget.cache_key.should == "NinjaTurtle:name:Leonardo:weapon:Dual Katanas:master:Splinter-Splinter"
      end
    end
    
    describe "_render_via_with_caching" do
      context "when there is a cache_with set" do
        it "stores the widgets output in LAWNCHAIR" do
          now = Time.now

          render_template do |controller|
            controller.render_widget Turtle, :name => "Leonardo", :weapon => "Dual Katanas", :master => @splinter
          end
          
          @output.should include("Weapon: Dual Katanas")
          expected_cached_at_time = @output.match(/Cached at: (.*)</)[1]
          
          sleep 1
          
          render_template do |controller|
            controller.render_widget Turtle, :name => "Leonardo", :weapon => "Dual Katanas", :master => @splinter
          end
          
          @output.should include("Cached at: #{expected_cached_at_time}")
        end
        
        context "when there are content interpolations set" do
          before do
            
          end
          
          it "displays the appropriate content" do
            expected_cached_at_time = Time.now.to_s(:db)

            render_template do |controller|
              controller.render_widget InterpolatedTurtle, :name => "Leonardo", :weapon => "Dual Katanas", :master => @splinter, :pizzas_eaten => "under 3000"
            end

            @output.should include("Weapon: Dual Katanas")
            @output.should include("under 3000")
            @output.should include("Cached at: #{expected_cached_at_time}")
            

            sleep 1

            render_template do |controller|
              controller.render_widget InterpolatedTurtle, :name => "Leonardo", :weapon => "Dual Katanas", :master => @splinter, :pizzas_eaten => "over 9000"
            end
            
            @output.should include("Cached at: #{expected_cached_at_time}")
            @output.should_not include("under 3000")
            @output.should include("over 9000")
          end
        end
      end
      
      context "when there is NO cache_with set" do
        class People < Erector::Widget
          def content
            widget Sheriff, :name => "Boss Hogg", :attitude => "Bad", :boys => ["good", "ol'"], :belly => :round
          end
        end
        
        class Sheriff < Erector::Widget
          def content
            div do
              div "Last failed to catch #{@boys.join('-')} boys: #{Time.now.to_s(:db)}"
              div "Name: #{@name}"
            end
          end
        end
        
        it "calls _render_via_without_caching" do
          render_template do |controller|
            controller.render_widget People
          end
          @output.should include("Name: Boss Hogg")
          expected_cached_at_time = @output.match(/boys: (.*)</)[1]
          sleep 1
          
          render_template do |controller|
            controller.render_widget People
          end
          @output.should_not include(expected_cached_at_time)
        end
      end
    end
    
  end
end
