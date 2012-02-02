module ErectorCache
  module AbstractWidget
    def self.included(base)
      base.module_eval do
        cattr_accessor :expire_in
        extend ClassMethods
        class_attribute :key_components
        class_attribute :interpolations
        include InstanceMethods
        alias_method_chain :_emit_via, :caching
      end
    end

    module ClassMethods
      def cache_with(*components)
        self.key_components = components
      end
      
      def interpolate(interpolations)
        self.interpolations = interpolations
      end
      
      def cache_for(ttl)
        self.expire_in = ttl
      end
      
      def expire!(hash={})
        hash = Hash.new("*").merge(hash)
        search_key = "Lawnchair:"+cache_key(hash, true)
        LAWNCHAIR.redis.keys(search_key).each{|key| LAWNCHAIR.redis.del(key) }
      end
      
      def cache_key(hash, wildcard=false)
        self.key_components.inject([self.to_s]) do |collection, part|
          key = (part.is_a?(Hash) ? part.keys.first : part)
          object = hash[key]

          if wildcard && object == "*"
            value = "*"
          elsif part.is_a?(Hash)
            value = Array(part[key]).map do |p| 
              if p.is_a?(Proc)
                p.call(object)
              else
                object.send(p)
              end
            end.join("-")
          else
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
      
      def _emit_via_with_caching(parent, options={})
        if self.class.key_components.blank?
          _emit_via_without_caching(parent, options)
        else
          options = {:expire_in => @expire_in || 1.hour, :raw => true}
          unless self.class.interpolations.blank?
            options[:interpolate] = self.class.interpolations.inject({}) do |collection, interpolation| 
              collection[interpolation.first] = self.instance_variable_get("@#{interpolation.last}")
              collection
            end
          end
          
          cached_fragment = LAWNCHAIR.cache(cache_key, options) do
            parent.capture { _emit_via_without_caching(parent, options) }
          end
          parent.output << cached_fragment.html_safe  
        end
      end
    end

  end
end

Erector::AbstractWidget.send(:include, ErectorCache::AbstractWidget)