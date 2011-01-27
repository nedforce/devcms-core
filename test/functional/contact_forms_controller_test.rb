require File.dirname(__FILE__) + '/../test_helper'

class ContactFormsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  def test_should_get_show
    cf = contact_forms(:help_form)
    get :show, :id => cf.id
    assert_response :success
    assert_equal cf, assigns(:contact_form)
    assert assigns(:contact_form_fields)
  end

  def test_should_render_404_if_not_found
    get :show, :id => -1
    assert_response :not_found
  end

end
