desc 'Set Rails environment to test'
task "rails_env:test" do
  RAILS_ENV = ENV['RAILS_ENV'] = 'test'
end

desc 'Setup database.yml for tests'
task "cruise:setup" do
  config = "test:
  adapter: postgresql
  database: devms_test_teamcity
  username: teamcity
  password: wESTuf9e"

  open("#{RAILS_ROOT}/config/database.yml", "w") do |database|
    database.write(config)
  end
end

desc 'Continuous build target'
task :cruise => [ "rails_env:test", "cruise:setup" ] do
  out = "#{RAILS_ROOT}/coverage"
  mkdir_p out unless File.directory?(out) if out

  exceptions = []

  begin
    ENV['SHOW_ONLY'] = 'models,helpers'
    Rake::Task["test:units:rcov"].invoke
  rescue => e
    exceptions << e
  end

  begin
    ENV['SHOW_ONLY'] = 'controllers,helpers'
    Rake::Task["test:functionals:rcov"].invoke
  rescue => e
    exceptions << e
  end

  exceptions.each { |e| puts e; puts e.backtrace }
  raise 'Test failures' unless exceptions.empty?
end
