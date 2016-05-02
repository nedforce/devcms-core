require File.expand_path('../../../test_helper.rb', __FILE__)

class Admin::ForumTopicsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  def test_should_show_forum_topic
    login_as :sjoerd    

    get :show, :id => forum_topics(:bewoners_forum_topic_wonen).id
    assert_response :success
    assert assigns(:forum_topic)
    assert_equal nodes(:bewoners_forum_topic_wonen_node), assigns(:node)
  end

  test 'should get new' do
    login_as :sjoerd

    get :new, :parent_node_id => nodes(:bewoners_forum_node).id
    assert_response :success
    assert assigns(:forum_topic)
  end

  test 'should get new with params' do
    login_as :sjoerd

    get :new, :parent_node_id => nodes(:bewoners_forum_node).id, :forum_topic => { :title => 'foo' }
    assert_response :success
    assert assigns(:forum_topic)
    assert_equal 'foo', assigns(:forum_topic).title
  end

  def test_should_create_forum_topic
    login_as :sjoerd

    assert_difference('ForumTopic.count') do
      create_forum_topic
      #assert_response :success
      refute assigns(:forum_topic).new_record?, assigns(:forum_topic).errors.full_messages.join('; ')
    end
  end

  def test_should_get_valid_preview_for_create
    login_as :sjoerd

    assert_no_difference('ForumTopic.count') do
      create_forum_topic({ :title => 'foobar' }, { :commit_type => 'preview' })
      assert_response :success
      assert assigns(:forum_topic).new_record?
      assert_equal 'foobar', assigns(:forum_topic).title
      assert_template 'create_preview'
    end
  end

  def test_should_not_get_invalid_preview_for_create
    login_as :sjoerd

    assert_no_difference('ForumTopic.count') do
      create_forum_topic({ :title => nil }, { :commit_type => 'preview' })
      assert_response :unprocessable_entity
      assert assigns(:forum_topic).new_record?
      assert assigns(:forum_topic).errors[:title].any?
      assert_template 'new'
    end
  end

  test 'should require title' do
    login_as :sjoerd

    assert_no_difference('ForumTopic.count') do
      create_forum_topic(:title => nil)
    end

    assert_response :unprocessable_entity
    assert assigns(:forum_topic).new_record?
    assert assigns(:forum_topic).errors[:title].any?
  end

  test 'should get edit' do
    login_as :sjoerd

    get :edit, :id => forum_topics(:bewoners_forum_topic_wonen).id
    assert_response :success
    assert assigns(:forum_topic)
  end

  test 'should get edit with params' do
    login_as :sjoerd

    get :edit, :id => forum_topics(:bewoners_forum_topic_wonen).id, :forum_topic => { :title => 'foo' }
    assert_response :success
    assert assigns(:forum_topic)
    assert_equal 'foo', assigns(:forum_topic).title
  end

  def test_should_update_forum_topic
    login_as :sjoerd

    put :update, :id => forum_topics(:bewoners_forum_topic_wonen).id, :forum_topic => { :title => 'updated title', :description => 'updated_body' }

    assert_response :success
    assert_equal 'updated title', assigns(:forum_topic).title
  end

  def test_should_get_valid_preview_for_update
    login_as :sjoerd

    forum_topic = forum_topics(:bewoners_forum_topic_wonen)
    old_title   = forum_topic.title
    put :update, :id => forum_topic, :forum_topic => { :title => 'updated title', :description => 'updated_body' }, :commit_type => 'preview'

    assert_response :success
    assert_equal 'updated title', assigns(:forum_topic).title
    assert_equal old_title, forum_topic.reload.title
    assert_template 'update_preview'
  end

  def test_should_not_get_invalid_preview_for_update
    login_as :sjoerd

    forum_topic = forum_topics(:bewoners_forum_topic_wonen)
    old_title   = forum_topic.title
    put :update, :id => forum_topic, :forum_topic => { :title => nil, :description => 'updated_body'}, :commit_type => 'preview'

    assert_response :unprocessable_entity
    assert assigns(:forum_topic).errors[:title].any?
    assert_equal old_title, forum_topic.reload.title
    assert_template 'edit'
  end

  def test_should_not_update_forum_topic
    login_as :sjoerd

    put :update, :id => forum_topics(:bewoners_forum_topic_wonen).id, :forum_topic => { :title => nil }
    assert_response :unprocessable_entity
    assert assigns(:forum_topic).errors[:title].any?
  end

protected

  def create_forum_topic(attributes = {}, options = {})
    post :create, { :parent_node_id => nodes(:bewoners_forum_node).id, :forum_topic => { :title => 'Some exciting title.', :description => 'Some exciting description.' }.merge(attributes) }.merge(options)
  end
end
