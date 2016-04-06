require File.expand_path('../../test_helper.rb', __FILE__)

# Unit tests for the +ResponseField+ model.
class ResponseFieldTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  setup do
    @response = responses(:one)
    @contact_form_field = contact_form_fields(:name)
  end

  test 'should create a responsefield' do
    assert_difference('ResponseField.count') do
      rsps = create_response_field
      refute rsps.new_record?
    end
  end

  test 'should allow file uploads' do
    assert_difference('ResponseField.count') do
      response = create_response_field(file: fixture_file_upload('files/ParkZandweerdMatrixplannen.doc', 'application/msword'))
      refute response.new_record?
      assert response.file?
    end
  end

  protected

  def create_response_field(options = {})
    ResponseField.create({
      response: @response,
      contact_form_field: @contact_form_field,
      value: 'Bas'
    }.merge(options))
  end
end
