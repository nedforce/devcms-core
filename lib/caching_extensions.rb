module ActionView #:nodoc:
  module Helpers #:nodoc:
    module CacheHelper

      # let cache accept a condition to decide wether or not to use the cache

      def cache_with_condition(options = {}, &block)
        do_cache = !options.has_key?(:do_cache) || options.delete(:do_cache)
        if do_cache
          cache_without_condition(options, &block)
        else
          yield
        end
      end

      alias_method_chain(:cache, :condition)
      
    end
  end
end