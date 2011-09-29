namespace :devcms do
  desc 'Run all unit, functional and integration tests'
  task :test do
    errors = %w(devcms:test:units devcms:test:functionals devcms:test:integration).collect do |task|
      begin
        Rake::Task[task].invoke
        nil
      rescue => e
        task
      end
    end.compact
    abort "Errors running #{errors.to_sentence(:locale => :en)}!" if errors.any?
  end

  namespace :test do
    Rake::TestTask.new(:units => "db:test:prepare") do |t|
      t.libs << "test"
      t.pattern = File.dirname(__FILE__) + '/../test/unit/**/*_test.rb'
      t.verbose = true
    end
    Rake::Task['test:units'].comment = "Run the unit tests in test/unit\n"

    Rake::TestTask.new(:functionals => "db:test:prepare") do |t|
      t.libs << "test"
      t.pattern = File.dirname(__FILE__) + '/../test/functional/**/*_test.rb'
      t.verbose = true
    end
    Rake::Task['test:functionals'].comment = "Run the functional tests in test/functional\n"

    Rake::TestTask.new(:integration => "db:test:prepare") do |t|
      t.libs << "test"
      t.pattern = File.dirname(__FILE__) + '/../test/integration/**/*_test.rb'
      t.verbose = true
    end
    Rake::Task['test:integration'].comment = "Run the integration tests in test/integration\n"
  end
end