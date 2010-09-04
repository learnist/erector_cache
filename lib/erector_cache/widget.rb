module ErectorCache
  module Widget
    def self.included(base)
      base.extend ClassMethods
      include InstanceMethods
    end

    module ClassMethods
      def cache_with(*components)
        class_inheritable_array :key_components
        self.key_components = components
      end
    end

    module InstanceMethods
      def cache_key
        
      end
    end
  end
end

Erector::Widget.send(:include, ErectorCache::Widget)