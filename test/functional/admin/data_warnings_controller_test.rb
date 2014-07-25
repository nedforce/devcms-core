require File.expand_path('../../../test_helper.rb', __FILE__)

class Admin::DataWarningsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  setup do
    @warning = DataChecker::DataWarning.create!(subject: Node.root.content, error_code: 'invalid_link', message: 'This is wrong!')
  end

  def test_should_show_warnings
    login_as :arthur
    get :index
    assert_response :success
  end

  def test_should_fetch_warnings
    login_as :arthur
    xhr :get, :index
    assert_response :success
  end

  def test_should_destroy_warnings
    login_as :arthur

    assert_difference 'DataChecker::DataWarning.count', -1 do
      xhr :delete, :destroy, :id => @warning.id
      assert_response :success
    end
  end

  def test_should_clear_warnings
    login_as :arthur

    assert_difference 'DataChecker::DataWarning.count', -1 do
      xhr :delete, :clear
      assert_response :success
    end
  end
end
