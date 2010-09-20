module ErectorCache
  module Widget
    def self.included(base)
      base.module_eval do
        cattr_accessor :expire_in
        extend ClassMethods
        class_inheritable_array :key_components
        include InstanceMethods
        alias_method_chain :_render_via, :caching
      end
    end

    module ClassMethods
      def cache_with(*components)
        self.key_components = components
      end
      
      def cache_for(ttl)
        self.expire_in = ttl
      end
      
      def expire!(hash={})
        hash = Hash.new("*").merge(hash)
        search_key = self.key_components.inject(["Lawnchair", self.to_s]) do |collection, part|
          p_prime = (part.is_a?(Hash) ? part.keys.first : part)
          collection << p_prime
          collection << if part.is_a?(Hash) && hash.keys.include?(p_prime)
            part[p_prime].call(hash[p_prime])
          else
            hash[p_prime.to_param]
          end
        end.join(":")
        
        LAWNCHAIR.redis.keys(search_key).split.each{|key| LAWNCHAIR.redis.del(key) }
      end
      
      def cache_key(hash)
        self.key_components.inject([self.to_s]) do |collection, part|
          object = part.is_a?(Hash) ? hash[part.keys.first] : hash[part]

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
      
      def _render_via_with_caching(parent, options={})
        if self.class.key_components.blank?
          _render_via_without_caching(parent, options)
        else
          options = {:expire_in => @expire_in || 1.hour}
          cached_fragment = LAWNCHAIR.cache(cache_key, options) do
            parent.capture { _render_via_without_caching(parent, options) }
          end
          parent.output << cached_fragment
        end
      end
    end
  end
end

Erector::Widget.send(:include, ErectorCache::Widget)