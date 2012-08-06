namespace :ferret do
  desc "Start, stop, run the ferret server"
  task :server, [:task] => :environment do |t, args| 
    p "Task should be start/stop/run" and exit(1) unless ['start', 'stop', 'run'].include?(args[:task])
    
    require 'acts_as_ferret/server/server'
    ActsAsFerret::Server::Server.new.send(args[:task]) 
  end
end