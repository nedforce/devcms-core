require File.dirname(__FILE__) + '/../../test_helper'

class Admin::FeedsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  def test_should_render_404_if_not_found
    login_as :sjoerd

    get :show, :id => -1
    assert_response :not_found
  end

  def test_should_get_new
    login_as :sjoerd

    get :new, :parent_node_id => nodes(:root_section_node).id
    assert_response :success
    assert assigns(:feed)
  end

  def test_should_create_feed
    login_as :sjoerd

    assert_difference('Feed.count') do
      create_feed
      assert !assigns(:feed).new_record?, :message => assigns(:feed).errors.full_messages.join('; ')
      assert_response :success
    end
  end

  def test_should_require_url
    login_as :sjoerd

    assert_no_difference('Feed.count') do
      create_feed(:url => nil)
    end
    
    assert_response :unprocessable_entity
    assert assigns(:feed).new_record?
    assert assigns(:feed).errors.on(:url)
  end

  def test_should_get_edit
    login_as :sjoerd

    create_feed

    get :edit, :id => assigns(:feed).id
    assert_response :success
    assert assigns(:feed)
  end

  def test_should_update_feed
    login_as :sjoerd
    create_feed
    put :update, :id => assigns(:feed).id, :feed => { :url => "http://office.nedforce.nl/dummy.xml" }

    assert_response :success
    assert_equal 'http://office.nedforce.nl/dummy.xml', assigns(:feed).url
  end

  def test_should_not_update_feed
    login_as :sjoerd
    create_feed
    put :update, :id => assigns(:feed).id, :feed => { :url => "http://office.nedforce.nl/robots.txt" }
    assert_response :unprocessable_entity
    assert assigns(:feed).errors.on(:url)
  end

  def test_should_require_roles
    assert_user_can_access  :arthur,       [ :new, :create ], { :parent_node_id => nodes(:root_section_node).id }
    assert_user_cant_access :final_editor, [ :new, :create ], { :parent_node_id => nodes(:economie_section_node).id }
    assert_user_cant_access :editor,       [ :new, :create ], { :parent_node_id => nodes(:devcms_news_node).id }
  end

  def test_should_create_test_with_title
    login_as :sjoerd

    create_feed({ :title => 'Test!!!' })

    assert assigns(:feed).title == 'Test!!!'
  end

  protected

  def create_feed(attributes = {}, options = {})
    post :create, { :parent_node_id => nodes(:root_section_node).id, :feed => { :url => "http://www.nedforce.nl/blog.rss" }.merge(attributes)}.merge(options)
  end
end
