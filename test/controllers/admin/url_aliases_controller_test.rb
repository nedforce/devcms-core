require File.expand_path('../../../test_helper.rb', __FILE__)

class Admin::UrlAliasesControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  def test_should_get_index
    login_as :sjoerd
    get :index
    assert_response :success
    assert assigns(:nodes)
  end

  def test_xml_index_should_contain_total_count
    login_as :sjoerd
    get :index, :format => 'xml'
    assert_response :success
    assert_select 'total_count', count: 1
  end

  def test_should_json_update_node
    login_as :sjoerd
    node = nodes(:yet_another_page_node)
    new_custom_url_suffix = 'koekenbakker'
    put :update, :id => node.id, :node => { :custom_url_suffix => new_custom_url_suffix }, :format => 'json'
    assert_response :success
    assert_equal Node.find(node.id).custom_url_suffix, new_custom_url_suffix
  end

  def test_should_not_json_update_illegal_custom_url_suffix
    login_as :sjoerd
    node = nodes(:yet_another_page_node)
    put :update, :id => node.id, :node => { :custom_url_suffix => 'ik@hou$van&lees(tekens' }, :format => 'json'
    assert_response :unprocessable_entity
    assert assigns(:node).errors[:custom_url_suffix].any?
  end

  def test_should_json_destroy_custom_url_alias
    login_as :sjoerd
    delete :destroy, :id => nodes(:yet_another_page_node).id, :format => 'json'
    assert_response :success
  end

  def test_should_page_for_extjs
    login_as :sjoerd
    get :index, :start => '2', :limit => '2', :format => 'xml'
    assert_response :success
    assert_equal 2, assigns(:nodes).size
    assert_select 'nodes', count: 1
  end

  def test_should_sort_for_extjs
    login_as :sjoerd
    get :index, :sort => 'custom_url_suffix', :dir => 'DESC', :format => 'xml'
    assert_response :success
    assert_equal nodes(:yet_another_page_node).content.title, assigns(:nodes).first.content.title
  end

  def test_should_page_and_sort_for_extjs
    login_as :sjoerd
    get :index, :sort => 'title', :dir => 'DESC', :start => '2', :limit => '2', :format => 'xml'
    assert_response :success
    assert_equal 2, assigns(:nodes).size
    assert_not_equal nodes(:yet_another_page_node).content.title, assigns(:nodes).first.content.title
  end

end
