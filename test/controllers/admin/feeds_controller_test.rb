require File.expand_path('../../../test_helper.rb', __FILE__)

class Admin::FeedsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  setup do
    login_as :sjoerd
  end

  test 'should get new' do
    get :new, parent_node_id: nodes(:root_section_node).id

    assert_response :success
    assert assigns(:feed)
  end

  test 'should create feed' do
    assert_difference('Feed.count') do
      VCR.use_cassette('feeds') do
        create_feed
      end

      refute assigns(:feed).new_record?, assigns(:feed).errors.full_messages.join('; ')
    end

    assert_response :success
  end

  test 'should require url' do
    assert_no_difference('Feed.count') do
      create_feed(url: nil)
    end

    assert_response :unprocessable_entity
    assert assigns(:feed).new_record?
    assert assigns(:feed).errors[:url].any?
  end

  test 'should get edit' do
    VCR.use_cassette('feeds') do
      create_feed
    end

    get :edit, id: assigns(:feed).id
    assert_response :success
    assert assigns(:feed)
  end

  test 'should create test with title' do
    create_feed(title: 'Test!!!')

    assert assigns(:feed).title == 'Test!!!'
  end

  protected

  def create_feed(attributes = {}, options = {})
    post :create, {
      parent_node_id: nodes(:root_section_node).id,
      feed: { url: 'http://www.nedforce.nl/blog.rss' }.merge(attributes)
    }.merge(options)
  end
end
