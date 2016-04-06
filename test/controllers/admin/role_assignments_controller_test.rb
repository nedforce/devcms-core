require File.expand_path('../../../test_helper.rb', __FILE__)

class Admin::RoleAssignmentsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  def test_should_get_index
    login_as :sjoerd
    get :index
    assert_response :success
  end

  def test_should_create_role_assignment
    login_as :sjoerd

    assert_difference('RoleAssignment.count') do
      create_role_assignment()
      assert_response :success
      refute assigns(:role_assignment).new_record?, assigns(:role_assignment).errors.full_messages.join('; ')
    end
  end

  def test_should_destroy_role_assignment
    login_as :sjoerd

    assert_difference('RoleAssignment.count', -1) do
      delete :destroy, :id => users(:editor).role_assignments.first.id, :format => 'json'
      assert_response :success
    end
  end

  def test_should_not_destroy_role_assignment_of_current_user
    login_as :sjoerd

    assert_no_difference('RoleAssignment.count') do
      delete :destroy, :id => users(:sjoerd).role_assignments.first.id, :format => 'json'
      assert_response :unprocessable_entity
    end
  end

  def test_should_require_role
    login_as :sjoerd

    assert_no_difference('RoleAssignment.count') do
      create_role_assignment({ :name => nil })
    end
    assert_response :success
    assert assigns(:role_assignment).new_record?
    assert assigns(:role_assignment).errors[:name].any?
  end

  def test_should_require_valid_role
    login_as :sjoerd

    assert_no_difference('RoleAssignment.count') do
      create_role_assignment({ :name => 'geen_rol' })
    end
    assert_response :success
    assert assigns(:role_assignment).new_record?
    assert assigns(:role_assignment).errors[:name].any?
  end

  test 'should require user' do
    login_as :sjoerd

    assert_no_difference('RoleAssignment.count') do
      create_role_assignment(user_login: nil)
    end
    assert_response :success
    assert assigns(:role_assignment).new_record?
    assert assigns(:role_assignment).errors[:user].any?
  end

  def test_should_page_for_extjs
    login_as :sjoerd
    get :index, :start => '2', :limit => '2', :format => 'json'
    assert_response :success
    assert_equal 2, assigns(:role_assignments).size
  end

  def test_should_sort_nodes_for_extjs
    login_as :sjoerd
    get :index, :sort => 'node_title', :dir => 'DESC', :format => 'json'
    assert_response :success
    assert_equal RoleAssignment.includes(:node).map { |ra| ra.node.content.content_title }.sort.last, assigns(:role_assignments).first.node.content.content_title
  end

  def test_should_sort_users_for_extjs
    login_as :sjoerd
    get :index, :sort => 'user_login', :dir => 'DESC', :format => 'json'
    assert_response :success
    assert_equal users(:sjoerd).login, assigns(:role_assignments).first.user.login
  end

  def test_should_sort_role_name_for_extjs
    login_as :sjoerd
    get :index, :sort => 'name', :dir => 'DESC', :format => 'json'
    assert_response :success
    assert_equal users(:reader).login, assigns(:role_assignments).first.user.login
  end

  def test_should_page_and_sort_for_extjs
    login_as :sjoerd
    get :index, :sort => 'node_title', :dir => 'ASC', :start => '5', :limit => '2', :format => 'json'
    assert_response :success
    assert_equal 2, assigns(:role_assignments).size
    assert_not_equal nodes(:contact_page_node).content.content_title, assigns(:role_assignments).last.node.content.content_title
  end

  protected

  def create_role_assignment(options = {})
    post :create, :node_id => nodes(:economie_section_node).id, :role_assignment => { :user_login => users(:privileged_user).login, :name => 'editor' }.merge(options)
  end
end
