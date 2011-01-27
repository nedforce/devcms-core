require File.dirname(__FILE__) + '/../../test_helper'

class Admin::SettingsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  def test_should_get_index
    login_as :sjoerd
    get :index
    assert_response :success
  end
  
  def test_should_update_setting
    login_as :sjoerd
    put :update, :id => Settler.search_default_engine.id, :setting => { :value => 'ferret' }
    assert_response :success    
  end

  def test_should_require_roles
    assert_user_can_access :arthur, :index
    assert_user_cant_access :editor, :index
    assert_user_cant_access :final_editor, :index
  end

end
