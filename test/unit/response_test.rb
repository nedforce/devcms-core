require File.expand_path('../../test_helper.rb', __FILE__)

class ResponseTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  def setup
    @help_form = contact_forms(:help_form)
  end

  test 'should create a response' do
    assert_difference('Response.count') do
      rsps = create_response
      assert !rsps.new_record?
    end
  end

  protected

  def create_response(options = {})
    Response.create({
      contact_form: @help_form,
      ip:           '127.0.0.1',
      time:         Time.zone.now
    }.merge(options))
  end
end
