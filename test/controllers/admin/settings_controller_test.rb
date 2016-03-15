require File.expand_path('../../../test_helper.rb', __FILE__)

# Functional tests for the +Admin::SettingsController+.
class Admin::SettingsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  setup do
    login_as :sjoerd
  end

  test 'should get index' do
    get :index

    assert_response :success
  end

  test 'should update setting' do
    put :update, id: Settler.after_signup_path.id, setting: { value: 'some/path' }

    assert_response :success
  end
end
