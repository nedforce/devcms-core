ENV['RAILS_ENV'] = 'test'

require File.expand_path('../../test/dummy/config/environment.rb',  __FILE__)
ActiveRecord::Migrator.migrations_paths = [File.expand_path('../../test/dummy/db/migrate', __FILE__)]
require 'rails/test_help'
require 'mocha/setup'
require 'byebug'

# Filter out Minitest backtrace while allowing backtrace from other libraries
# to be shown.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path('../fixtures', __FILE__)
  ActionDispatch::IntegrationTest.fixture_path = ActiveSupport::TestCase.fixture_path
  ActiveSupport::TestCase.fixtures :all
end

include ActionDispatch::TestProcess # Required to make fixture_file_upload work

# Truncate all tables first
ActiveRecord::Base.connection.tables.each { |table| ActiveRecord::Base.connection.execute("TRUNCATE #{table} CASCADE") }

# Initialize Settler
Settler.load!

# Fixture helpers
module FixtureHelpers
  def fixtures_to_ancestry(*names)
    names.map { |name| ActiveRecord::FixtureSet.identify(name) }.join('/')
  end
end

ActiveRecord::FixtureSet.context_class.include FixtureHelpers

class ActiveSupport::TestCase
  # Add more helper methods to be used by all tests here...
  include DevcmsCore::AuthenticatedTestHelper
  include DevcmsCore::RoleRequirementTestHelper
  include DevcmsCore::RoutingHelpers

  # Headhunter: Check HTML by setting HEADHUNTER env variable:
  # ENV['HEADHUNTER'] = true

  def get_file_as_string(filename)
    data = ''
    f = File.open(File.dirname(__FILE__) + "/fixtures/#{filename}")
    f.read
  end

  def with_constants(constants, &block)
    constants.each do |constant, val|
      Object.const_set(constant, val)
    end

    block.call

    constants.each do |constant, _val|
      Object.send(:remove_const, constant)
    end
  end

  def with_csrf_check_enabled(&block)
    begin
      ActionController::Base.allow_forgery_protection = true
      yield
    ensure
      ActionController::Base.allow_forgery_protection = false
    end
  end
end

class ActionDispatch::IntegrationTest
  self.fixture_path = File.dirname(__FILE__) + '/fixtures/'

  setup :enable_show_exceptions

  def enable_show_exceptions
    Rails.application.config.stubs(:consider_all_requests_local).returns(false)
    Rails.application.config.action_dispatch.stubs(:show_exceptions).returns(true)
  end
end
