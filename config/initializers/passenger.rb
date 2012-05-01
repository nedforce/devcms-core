# Using acts as ferret with phusion passenger / mod_rails
# http://pennysmalls.com/2009/03/02/using-acts-as-ferret-with-phusion-passenger-mod_rails/
if defined?(PhusionPassenger) && defined?(DRb)
  # monkey patch drb so we can close its connections
  class DRb::DRbConn
    def self.close_all
      @mutex.synchronize do
        @pool.each {|c| c.close}
        @pool = []
      end
    end
  end

  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    if forked
      # We're in smart spawning mode.
      DRb::DRbConn.close_all  # ferret
    else
      # We're in conservative spawning mode. We don't need to do anything.
    end
  end
end
