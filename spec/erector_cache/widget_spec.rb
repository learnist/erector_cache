require 'spec_helper'

class Turtle < Erector::Widget
  cache_with :age
end

class NinjaTurtle < Turtle
  cache_with :name
end

describe ErectorCache::Widget do
  describe ".cache_with" do
    it "sets the attributes to cache instances of this widget with" do
      Turtle.key_components.should == [:age]
    end
    
    it "inherits parent classes cache key components" do
      NinjaTurtle.key_components.should == [:age, :name]
    end
  end
end
