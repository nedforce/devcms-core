require File.dirname(__FILE__) + '/../../test_helper'

class Admin::SearchPagesControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  def test_should_render_404_if_not_found
    login_as :sjoerd

    get :show, :id => -1
    assert_response :not_found
  end

  def test_should_show_forum
    login_as :sjoerd    

    get :show, :id => search_pages(:standard_search_page).id
    assert_response :success
    assert assigns(:search_page)
    assert_equal nodes(:standard_search_page_node), assigns(:node)
  end

  def test_should_get_new
    login_as :sjoerd

    get :new, :parent_node_id => nodes(:root_section_node).id
    assert_response :success
    assert assigns(:search_page)
  end

  def test_should_get_new_with_params
    login_as :sjoerd

    get :new, :parent_node_id => nodes(:root_section_node).id, :search_page => { :title => 'foo' }
    assert_response :success
    assert assigns(:search_page)
    assert_equal 'foo', assigns(:search_page).title
  end
  
  def test_should_create_search_page
    login_as :sjoerd
    
    assert_difference('SearchPage.count') do
      create_search_page
      assert_response :success
      assert !assigns(:search_page).new_record?, :message => assigns(:search_page).errors.full_messages.join('; ')
    end
  end

  def test_should_require_title
    login_as :sjoerd

    assert_no_difference('SearchPage.count') do
      create_search_page(:title => nil)
    end

    assert_response :success
    assert assigns(:search_page).new_record?
    assert assigns(:search_page).errors.on(:title)
  end

  def test_should_get_edit
    login_as :sjoerd

    get :edit, :id => search_pages(:standard_search_page).id
    assert_response :success
    assert assigns(:search_page)
  end

  def test_should_get_edit_with_params
    login_as :sjoerd

    get :edit, :id => search_pages(:standard_search_page).id, :search_page => { :title => 'foo' }
    assert_response :success
    assert assigns(:search_page)
    assert_equal 'foo', assigns(:search_page).title
  end

  def test_should_update_search_page
    login_as :sjoerd

    put :update, :id => search_pages(:standard_search_page).id, :search_page => { :title => 'updated title' }

    assert_response :success
    assert_equal 'updated title', assigns(:search_page).title
  end

  def test_should_not_update_search_page
    login_as :sjoerd

    put :update, :id => search_pages(:standard_search_page).id, :search_page => {:title => nil}
    assert_response :success
    assert assigns(:search_page).errors.on(:title)
  end

  protected

  def create_search_page(attributes = {}, options = {})
    post :create, { :parent_node_id => nodes(:root_section_node).id, :search_page => { :title => 'Some exciting title' }.merge(attributes) }.merge(options)
  end
end
