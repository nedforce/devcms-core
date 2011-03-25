default_run_options[:pty] = false

set :use_sudo, false
set :synchronous_connect, true
set :deploy_via, :remote_cache
set :keep_releases, 2

set :repository, "git@office.nedforce.nl:treehouse.git"
set :scm, "git"
set :scm_verbose, true

# Set the path to the private key for the deploy account.
#  *nix: ~/.ssh/devcms_dsa
#  Windows 2000/XP: C:/Documents and Settings/username/.ssh/devcms_dsa
#  Windows Vista: C:/Users/username/.ssh/devcms_dsa
task :acceptance do
  ssh_options[:keys] = %w(/path/to/home/.ssh/devcms_dsa)
  server "77.222.72.243", :app, :web, :db, :primary => true
  server "77.222.72.244", :app, :web, :db, :primary => true
  ssh_options[:username] = "deploy"
  set :application, "devcms"
  set :deploy_to, "/home/deploy/acceptance"
  set :db_name, "devcmsdev"
  set :branch, "master"
end

task :production do
  ssh_options[:keys] = %w(/path/to/home/.ssh/devcms_dsa)
  server "77.222.72.243", :app, :web, :db, :primary => true
  server "77.222.72.244", :app, :web, :db, :primary => true
  ssh_options[:username] = "deploy"
  set :application, "devcms"
  set :deploy_to, "/home/deploy/production"
  set :db_name, "devcmsprod"
  set :branch, "master"
end

before "deploy:migrate", "deploy:web:disable"

after "deploy:setup", "configure:setup"#, "configure:update"
after "deploy:update_code", "configure:link", "deploy:cleanup", "deploy:update_assets", "deploy:migrate", "deploy:web:enable"

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
  desc "Create asset packages for production" 
   task :update_assets, :roles => [:web] do
     run <<-EOF
       cd #{release_path} && rake asset:packager:build_all
     EOF
   end
end

# namespace :monit do
  namespace :ferret do
    [:start, :stop, :restart].each do |t|
      desc "Not applicable."
      task t, :roles => :app do ; end
    end
  end
# end

namespace :configure do
  desc "Create shared/config and configuration files"
  task :setup, :roles => [:app] do
    # run "mkdir -p #{deploy_to}/#{shared_dir}/config/monit.d"
    # sudo "ln -nfs #{deploy_to}/#{shared_dir}/config/monit.d/ferret.conf /etc/monit.d/ferret.conf", :pty => true
    run "mkdir -p #{deploy_to}/#{shared_dir}/system/cache"
  end

  desc "Link in the production cache, index and configuration files"
  task :link, :roles => [:app] do
    run "ln -nfs #{deploy_to}/#{shared_dir}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{deploy_to}/#{shared_dir}/system/cache #{release_path}/public/cache"
    run "ln -nfs #{deploy_to}/#{shared_dir}/system/index #{release_path}/index"
  end

  desc "Generate and reload monit configuration"
  task :reload, :roles => [:app] do
    monit
    sudo "monit reload", :pty => true
  end

  desc "Generate Monit configuration files."
  task :monit, :roles => [:app] do
    monitrc = ''

    monitrc = <<EOT
check process ferret with pidfile /home/deploy/current/tmp/pids/ferret.pid
  start program = "/bin/su deploy -c /opt/ruby-enterprise/bin/ruby /home/deploy/current/script/start_ferret"
  stop program = "/bin/su deploy -c /opt/ruby-enterprise/bin/ruby /home/deploy/current/script/stop_ferret"

# let ferret manage it's own memory. it caches agressively.
#  if totalmem is greater than 300.0 MB for 10 cycles then restart       # eating up memory?

  if cpu is greater than 50% for 2 cycles then alert                  # send an email to admin
  if cpu is greater than 80% for 3 cycles then restart                # hung process?
  if loadavg(5min) greater than 10 for 8 cycles then restart          # bad, bad, bad
  if 3 restarts within 5 cycles then timeout                         # something is wrong, call the sys-admin

  if failed
    url http://87.249.121.117/search?q=test
    with timeout 30 seconds
    then restart
EOT
    put monitrc, "#{deploy_to}/#{shared_dir}/config/monit.d/ferret.conf"
  end

  desc "Generate database.yml skeleton"
  task :database, :roles => [:app] do
    database_configuration = <<-EOF
login: &login
  adapter: ibm_db
  host: 87.249.121.116
  port: 50000
  database: #{db_name}
  username: db2udvtr
  password:

test:
  schema: test
  <<: *login

production:
  schema: production
  <<: *login
EOF
  put database_configuration, "#{deploy_to}/#{shared_dir}/config/database.yml"
  end
end