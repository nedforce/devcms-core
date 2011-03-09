require File.dirname(__FILE__) + '/../test_helper'

class ResponseFieldTest < ActiveSupport::TestCase
  
  self.use_transactional_fixtures = true
  
  def setup
    @response = responses(:one)
    @contact_form_field = contact_form_fields(:name)
  end
  
  test "should create a responsefield" do
    assert_difference('ResponseField.count') do
      rsps = create_response_field
      assert !rsps.new_record?
    end
  end
  
  
  protected

  def create_response_field(options = {})
    ResponseField.create({
      :response => @response,
      :contact_form_field => @contact_form_field,
      :value => 'Bas'
    }.merge(options))
  end
end

