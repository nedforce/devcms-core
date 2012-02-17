module ActionView #:nodoc:
  class Base #:nodoc:
    # adds support for expiring of cached fragment
    def cache(key, options = {}, &block)
      enabled = options.delete(:enabled)
      
      if enabled
        expires_in = key.delete(:expires_in)
        key[:host] = Settler[:host]
        options[:expires_in] = expires_in.to_i if expires_in.present?
        
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
