module ErectorCache
  module Widget
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def cache_with(*components)
        class_inheritable_array :key_components
        include InstanceMethods
        self.key_components = components
      end
      
      def cache_key(hash)
        self.key_components.inject([self.to_s]) do |collection, part|
          object = part.is_a?(Hash) ? hash[part.keys.first] : hash[part]

          if object.respond_to?(:to_param)
            if part.is_a?(Hash)
              key = part.keys.first
              value = Array(part[key]).map do |p| 
                if p.is_a?(Proc)
                  p.call(object)
                else
                  object.send(p)
                end
              end.join("-")
            else
              key = part
              value = object.to_param
            end
            collection << [key, value]
          else
            collection << [part, object]
          end
          collection
        end.flatten.join(":")
      end
    end

    module InstanceMethods
      def cache_key
        key_data = {}
        self.class.key_components.each do |part|
          part = part.keys.first if part.is_a?(Hash)
          key_data[part] = self.instance_variable_get("@#{part}")
        end
        return self.class.cache_key(key_data)
      end
    end
  end
end

Erector::Widget.send(:include, ErectorCache::Widget)