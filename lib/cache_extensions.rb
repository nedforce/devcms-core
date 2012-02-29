module ActionView #:nodoc:
  class Base #:nodoc:
    # adds support for expiring of cached fragment
    def cache(key, options = {}, &block)
      enabled = !options.keys.include?(:enabled) || options.delete(:enabled)
      
      if enabled
        key[:host] = Settler[:host]
        expires_in = key.delete(:expires_in)         
        if ActionController::Base.cache_store.is_a?(ActiveSupport::Cache::MemCacheStore)
          options[:expires_in] = expires_in.to_i if expires_in.present?
        else
          key.update(:ttl => (Time.now.to_i / expires_in.to_i)) if expires_in.present?
        end
        
        begin
          super(key, options, &block) 
        rescue Memcached::ServerIsMarkedDead => e
          BackgroundNotifier.deliver_exception_notification(e, "Caching", nil)
          yield
        end
      else
        yield
      end
    end
  end
end
