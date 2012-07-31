module ActionController #:nodoc:
  module Caching
    module Fragments
      # Caching actions use non-existent routes, therefore url_for 
      # should not be used to generate the cache key.
      def fragment_cache_key(key)
        ActiveSupport::Cache.expand_cache_key(key.is_a?(Hash) ? key.to_query : key, :views)        
      end
    end
  end
end