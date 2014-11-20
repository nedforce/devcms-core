require File.expand_path('../../../test_helper.rb', __FILE__)

class Admin::SettingsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  def test_should_get_index
    login_as :sjoerd
    get :index
    assert_response :success
  end

  def test_should_update_setting
    login_as :sjoerd
    put :update, :id => Settler.after_signup_path.id, :setting => { :value => 'some/path' }
    assert_response :success
  end

end
