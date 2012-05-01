require File.expand_path('../../../test_helper.rb', __FILE__)

class Admin::UsersControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  def test_should_get_index
    login_as :sjoerd
    get :index
    assert_response :success
    assert assigns(:users)
  end

  def test_should_get_csv_list_to_export_users
    login_as :sjoerd
    get :index, :format => 'csv'
    assert_response :success
    assert assigns(:users)
  end

  def test_xml_index_should_contain_total_count
    login_as :sjoerd
    get :index, :format => 'xml'
    assert_response :success
    assert_tag :tag => 'total_count'
  end

  def test_should_xml_update_user
    login_as :sjoerd
    arthur = users(:arthur)
    new_name = 'boes'
    put :update, :id => arthur.id, :user => { :first_name => new_name }, :format => 'xml'
    assert_response :success
    assert_equal User.find(arthur.id).first_name, new_name
  end

  def test_should_not_xml_update_illegal_email_address
    login_as :sjoerd
    arthur = users(:arthur)
    put :update, :id => arthur.id, :user => { :email_address => 'arthur@invalid' }, :format => 'xml'
    assert_response :unprocessable_entity
    assert assigns(:user).errors[:email_address].any?
  end

  def test_should_json_update_user
    login_as :sjoerd
    arthur = users(:arthur)
    new_name = 'boes'
    put :update, :id => arthur.id, :user => { :first_name => new_name }, :format => 'json'
    assert_response :success
    assert_equal User.find(arthur.id).first_name, new_name
  end

  def test_should_json_destroy_user
    login_as :sjoerd
    delete :destroy, :id => users(:arthur).id, :format => 'json'
    assert_response :success
  end

  def test_should_not_destroy_current_user
    login_as :sjoerd
    delete :destroy, :id => users(:sjoerd).id, :format => 'json'
    assert_response :unprocessable_entity
  end

  def test_should_json_get_newsletter_archives_for_user
    login_as :sjoerd
    get :accessible_newsletter_archives, :id => users(:sjoerd).id, :format => 'json'
    assert_response :success
  end

  def test_should_json_get_interests_for_user
    login_as :sjoerd
    get :interests, :id => users(:sjoerd).id, :format => 'json'
    assert_response :success
  end

  def test_should_page_for_extjs
    login_as :sjoerd
    get :index, :start => '2', :limit => '2', :format => 'xml'
    assert_response :success
    assert_equal 2, assigns(:users).size
    assert_tag :tag => 'users'
  end

  def test_should_sort_for_extjs
    login_as :sjoerd
    get :index, :sort => 'email_address', :dir => 'DESC', :format => 'xml'
    assert_response :success
    assert_equal users(:gerjan).email_address, assigns(:users).first.email_address
  end

  def test_should_sort_newsletter_archives_for_extjs
    login_as :sjoerd
    get :index, :sort => 'newsletter_archives', :dir => 'DESC', :format => 'xml'
    assert_response :success
    assert_equal users(:sjoerd).email_address, assigns(:users).first.email_address
  end

  def test_should_page_and_sort_for_extjs
    login_as :sjoerd
    get :index, :sort => 'email_address', :dir => 'DESC', :start => '2', :limit => '2', :format => 'xml'
    assert_response :success
    assert_equal 2, assigns(:users).size
    assert_not_equal users(:gerjan).email_address, assigns(:users).first.email_address
  end

  def test_should_filter_for_extjs
    login_as :sjoerd
    get :index, :filter => { 0 => { :data => { :type => 'string', :value => 'a' }, :field => 'login' } }, :format => 'xml'

    assert_response :success
    assert_equal 1, assigns(:users).size
    assert_equal users(:arthur).login, assigns(:users).first.login
  end

  def test_should_invite
    login_as :sjoerd

    ActionMailer::Base.deliveries.clear

    post :invite, :email_address => 'test@test.nl'

    assert_equal 1, ActionMailer::Base.deliveries.size

    email = ActionMailer::Base.deliveries.first
    
    assert email.to.include?('test@test.nl')
  end

end

