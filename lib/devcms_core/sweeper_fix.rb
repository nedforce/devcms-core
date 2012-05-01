module ActionController
  module Caching
    class Sweeper
      def controller
        Thread.current[:"#{self}_controller"] || ActionController::Base.new
      end

      def controller=(c)
        Thread.current[:"#{self}_controller"] = c
      end
    end
  end
end