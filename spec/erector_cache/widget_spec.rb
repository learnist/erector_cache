require 'spec_helper'

class Turtle < Erector::Widget
  cache_with :name
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
  end
  
  describe "InstanceMethods" do
    describe "#cache_key" do
      it "builds a simple cache key for an instance properly" do
        widget = Turtle.new(:name => "Yertle")
        widget.cache_key.should == "Turtle:name:Yertle"
      end
      
      it "builds a complex cache key" do
        widget = NinjaTurtle.new(:name => "Leonardo", :master => @splinter, :weapon => :ninjaken)
        widget.cache_key.should == "NinjaTurtle:name:Leonardo:weapon:ninjaken:master:Splinter"
      end
    end
  end
end
