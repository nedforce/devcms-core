require File.expand_path('../../../test_helper.rb', __FILE__)

class Admin::LinksControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true
  
  def setup
    @link = links(:internal_link)
  end

  def test_should_get_show
    login_as :sjoerd

    get :show, :id => @link
    assert assigns(:link)
    assert_response :success
    assert_equal @link.node, assigns(:node)
  end

  def test_should_get_previous
    @link.save :user => User.find_by_login('editor')
    
    login_as :sjoerd
    
    get :previous, :id => @link
    assert_response :success
    assert assigns(:link)
  end
  
  def test_should_get_new
    login_as :sjoerd
    
    get :new, :parent_node_id => nodes(:root_section_node).id
    assert_response :success
    assert assigns(:link)
  end
  
  def test_should_create_internal_link
    login_as :sjoerd
    
    assert_difference('InternalLink.count') do
      create_link(:linked_node_id => nodes(:root_section_node).id, :type => 'InternalLink')
      assert_response :success
      assert !assigns(:link).new_record?, assigns(:link).errors.full_messages.join('; ')
    end
  end
  
  def test_should_create_external_link
    login_as :sjoerd
    
    assert_difference('ExternalLink.count') do
      create_link(:url => 'http://www.google.com', :type => 'ExternalLink')
      assert_response :success
      assert !assigns(:link).new_record?, assigns(:link).errors.full_messages.join('; ')
    end
  end
  
  def test_should_require_type
    login_as :sjoerd
    
    assert_no_difference('Link.count') do
      create_link()
    end
    
    assert_response :unprocessable_entity
    assert assigns(:link).new_record?
    assert assigns(:link).errors[:type].any?
  end
  
  def test_should_require_url_for_external_link
    login_as :sjoerd
    
    assert_no_difference('ExternalLink.count') do
      create_link(:url => nil, :type => 'ExternalLink')
    end
    
    assert_response :unprocessable_entity
    assert assigns(:link).new_record?
    assert assigns(:link).errors[:url].any?
  end
  
  def test_should_require_linked_node_id_for_internal_link
    login_as :sjoerd
    
    assert_no_difference('InternalLink.count') do
      create_link(:linked_node_id => nil, :type => 'InternalLink')
    end
    
    assert_response :unprocessable_entity
    assert assigns(:link).new_record?
    assert assigns(:link).errors[:linked_node].any?
  end
  
  def test_should_get_edit
    login_as :sjoerd
    
    get :edit, :id => links(:internal_link).id
    assert_response :success
    assert assigns(:link)
  end
  
  def test_should_update_link
    login_as :sjoerd
    
    put :update, :id => links(:internal_link).id, :link => { :title => 'updated title', :description => 'updated description' }
    
    assert_response :success
    assert_equal 'updated title', assigns(:link).title
  end
  
  def test_should_not_update_link
    login_as :sjoerd
    
    put :update, :id => links(:internal_link).id, :link => { :linked_node_id => nil }
    assert_response :unprocessable_entity
    assert assigns(:link).errors[:linked_node].any?
  end

protected
  
  def create_link(attributes = {}, options = {})
    post :create, { :parent_node_id => nodes(:root_section_node).id, :link => { :title => 'new title', :description => 'Lorem ipsum' }.merge(attributes)}.merge(options)
  end
end
