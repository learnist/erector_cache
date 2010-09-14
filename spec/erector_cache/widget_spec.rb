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
    name
  end
end

class NinjaTurtle < Turtle
  cache_with :weapon, :master => lambda {|m| m.name }
  cache_for 25.years
  
  def content
    span "Weapon: #{@weapon}"
    span "Cached at: #{Time.now.to_s(:db)}"
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
        widget.cache_key.should == "NinjaTurtle:name:Leonardo:weapon:Dual Katanas:master:Splinter"
      end
    end
    
    describe "_render_via_with_caching" do
      context "when there is a cache_with set" do
        it "stores the widgets output in Lawnchair" do
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
      end
      
      context "when there is NO cache_with set" do
        it "calls _render_via_without_caching"
      end
    end
    
  end
end
