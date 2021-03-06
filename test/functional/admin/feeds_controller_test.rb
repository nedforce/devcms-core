require File.expand_path('../../../test_helper.rb', __FILE__)

class Admin::FeedsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

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
      assert !assigns(:feed).new_record?, assigns(:feed).errors.full_messages.join('; ')
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
    assert assigns(:feed).errors[:url].any?
  end

  def test_should_get_edit
    login_as :sjoerd

    create_feed

    get :edit, :id => assigns(:feed).id
    assert_response :success
    assert assigns(:feed)
  end

  def test_should_create_test_with_title
    login_as :sjoerd

    create_feed({ :title => 'Test!!!' })

    assert assigns(:feed).title == 'Test!!!'
  end

  protected

  def create_feed(attributes = {}, options = {})
    post :create, { :parent_node_id => nodes(:root_section_node).id, :feed => { :url => 'http://www.nedforce.nl/blog.rss' }.merge(attributes) }.merge(options)
  end
end
