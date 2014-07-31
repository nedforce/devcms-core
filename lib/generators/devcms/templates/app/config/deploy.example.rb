require 'bundler/capistrano'

default_run_options[:pty] = false

set :use_sudo, false
set :synchronous_connect, true
set :deploy_via, :remote_cache
set :keep_releases, 2

set :repository, "git@office.nedforce.nl:devcms.git"
set :scm, "git"
set :scm_verbose, true

# Set the path to the private key for the deploy account.
#  *nix: ~/.ssh/devcms_dsa
#  Windows 2000/XP: C:/Documents and Settings/username/.ssh/devcms_dsa
#  Windows Vista: C:/Users/username/.ssh/devcms_dsa
task :acceptance do
  ssh_options[:keys] = %w(/path/to/home/.ssh/id_dsa)
  server "77.222.72.243", :app, :web, :db, :primary => true
  server "77.222.72.244", :app, :web, :db, :primary => true
  ssh_options[:username] = "deploy"
  set :application, "devcms"
  set :deploy_to, "/home/deploy/acceptance"
  set :db_name, "devcmsdev"
  set :branch, "master"
end

task :production do
  ssh_options[:keys] = %w(/path/to/home/.ssh/id_dsa)
  server "77.222.72.243", :app, :web, :db, :primary => true
  server "77.222.72.244", :app, :web, :db, :primary => true
  ssh_options[:username] = "deploy"
  set :application, "devcms"
  set :deploy_to, "/home/deploy/production"
  set :db_name, "devcmsprod"
  set :branch, "master"
end

after "deploy:update_code", "configure:setup", "configure:link", "deploy:migrate", "deploy:precompile_assets", "deploy:link_uploads"
after "deploy:restart", "deploy:cleanup"

namespace :deploy do
  desc "Restart application"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end
  [:start, :stop].each do |t|
    desc "Not applicable for Passenger"
    task t, :roles => :app do ; end
  end
  #
  # desc <<-DESC
  #   Rebuilds the Node index for Ferret.
  # DESC
  # task :rebuild_index, :roles => :app do
  #   run "echo \"Node.all.each { |n| n.ferret_update } ; quit\" | #{current_path}/script/console production"
  # end

  task :precompile_assets, :roles => :app do
    run "cd #{release_path}; RAILS_ENV=#{rails_env} #{rake} assets:precompile"  
  end

  desc "Symlink uploads dir"
  task :link_uploads, :roles => :db do
    run "mkdir -p #{deploy_to}/#{shared_dir}/uploads"
    run "ln -nfs #{deploy_to}/#{shared_dir}/uploads #{release_path}/public/uploads"

    run "mkdir -p #{deploy_to}/#{shared_dir}/private_uploads"
    run "ln -nfs #{deploy_to}/#{shared_dir}/private_uploads #{release_path}/private/uploads"
  end
end

namespace :ferret do
  [:start, :stop, :restart].each do |t|
    desc "Not applicable."
    task t, :roles => :app do ; end
  end
end

namespace :configure do
  desc "Create shared/config and configuration files"
  task :setup, :roles => [:app] do
    run "mkdir -p #{deploy_to}/#{shared_dir}/system/cache"
  end

  desc "Link in the production cache, index and configuration files"
  task :link, :roles => [:app] do
    run "ln -nfs #{deploy_to}/#{shared_dir}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{deploy_to}/#{shared_dir}/system/cache #{release_path}/public/cache"
    run "ln -nfs #{deploy_to}/#{shared_dir}/system/index #{release_path}/index"
  end
end
