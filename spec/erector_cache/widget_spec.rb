require 'spec_helper'

class Turtle < Erector::Widget
  cache_with :name
end

class NinjaTurtle < Turtle
  cache_with :weapon
end

describe ErectorCache::Widget do
  describe "ClassMethods" do
    describe ".cache_with" do
      it "sets the attributes to cache instances of this widget with" do
        Turtle.key_components.should == [:name]
      end

      it "inherits parent classes cache key components" do
        NinjaTurtle.key_components.should == [:name, :weapon]
      end
    end
  end
  
  describe "InstanceMethods" do
    describe "#cache_key" do
      it "builds a simple cache key for an instance properly" do
        widget = Turtle.new(:name => "Yertle")
        widget.cache_key.should == "Turtle:name:Yertle"
      end
    end
  end
end
