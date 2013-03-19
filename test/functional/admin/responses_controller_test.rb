require File.expand_path('../../../test_helper.rb', __FILE__)

class Admin::ResponsesControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  def test_should_get_csv
    login_as :sjoerd
    get :index, :contact_form => contact_forms(:help_form), :format => 'csv'
    assert_response :success
  end

  def test_should_get_xls
    login_as :sjoerd
    get :index, :contact_form => contact_forms(:help_form), :format => 'xls'
    assert_response :success
  end

  def test_should_get_xml
    login_as :sjoerd
    get :index, :contact_form => contact_forms(:help_form), :format => 'xml'
    assert_response :success
  end
end
