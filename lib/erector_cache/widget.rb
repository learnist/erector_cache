module ErectorCache
  module Widget
    def self.included(base)
      base.extend ClassMethods
      base.send :include, Singletons
    end

    module ClassMethods
      @key_components = []
      def key_components
        @key_components
      end
      
      def cache_with(*key_components)
        @key_components = key_components
      end
    end
    
    module Singletons
      def cache_key
        puts "WOOOOOO"
      end
    end
  end
end

Erector::Widget.send(:include, ErectorCache::Widget)