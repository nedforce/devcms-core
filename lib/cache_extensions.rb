module ActionView #:nodoc:
 class Base #:nodoc:
   # adds support for expiring of cached fragment
   def cache(key, options = {}, &block)
     begin
       super(key, options, &block) 
     rescue Memcached::ServerIsMarkedDead => e
       BackgroundNotifier.deliver_exception_notification(e, "Caching", nil)
       yield
     end
   end
 end
end
