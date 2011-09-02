module ActionView #:nodoc:
 class Base #:nodoc:
   # adds support for expiring of cached fragment
   def cache(key, options = {}, &block)
     expires_in = options.delete(:expires_in)         
     options.update(:ttl => (Time.now.to_i / expires_in.to_i)) if expires_in
     begin
       super(key, options, &block) 
     rescue Memcached::ServerIsMarkedDead => e
       BackgroundNotifier.exception_notification(e, "Caching", nil)
       yield
     end
   end
 end
end
