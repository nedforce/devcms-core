require File.expand_path('../../../test_helper.rb', __FILE__)

# Functional tests for the +Admin::WeblogPostsController+.
class Admin::WeblogPostsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  setup do
    login_as :sjoerd
  end

  test 'should show weblog post' do
    get :show, parent_node_id: nodes(:henk_weblog_node).id, id: weblog_posts(:henk_weblog_post_one).id

    assert_response :success
    assert assigns(:weblog_post)
    assert_equal weblog_posts(:henk_weblog_post_one).node, assigns(:node)
  end

  test 'should get edit' do
    get :edit, id: weblog_posts(:henk_weblog_post_one).id

    assert_response :success
    assert assigns(:weblog_post)
  end

  test 'should get edit with params' do
    get :edit, id: weblog_posts(:henk_weblog_post_one).id, weblog_post: { title: 'foo' }

    assert_response :success
    assert assigns(:weblog_post)
    assert_equal 'foo', assigns(:weblog_post).title
  end

  test 'should update weblog post' do
    put :update, id: weblog_posts(:henk_weblog_post_one).id, weblog_post: { title: 'updated title', body: 'updated body' }

    assert_response :success
    assert_equal 'updated title', assigns(:weblog_post).title
  end

  test 'should get valid preview for update' do
    weblog_post = weblog_posts(:henk_weblog_post_one)
    old_title = weblog_post.title
    put :update, id: weblog_post, weblog_post: { title: 'updated title', body: 'updated body' }, commit_type: 'preview'

    assert_response :success
    assert_equal 'updated title', assigns(:weblog_post).title
    assert_equal old_title, weblog_post.reload.title
    assert_template 'update_preview'
  end

  test 'should not get invalid preview for update' do
    weblog_post = weblog_posts(:henk_weblog_post_one)
    old_title = weblog_post.title
    put :update, id: weblog_post, weblog_post: { title: nil, body: 'updated body' }, commit_type: 'preview'

    assert_response :unprocessable_entity
    assert assigns(:weblog_post).errors[:title].any?
    assert_equal old_title, weblog_post.reload.title
    assert_template 'edit'
  end

  test 'should not update weblog post with invalid date' do
    put :update, id: weblog_posts(:henk_weblog_post_one), weblog_post: { title: nil }

    assert_response :unprocessable_entity
    assert assigns(:weblog_post).errors[:title].any?
  end

  test 'should set publication start date on update' do
    date = 1.year.from_now

    put :update, id: weblog_posts(:henk_weblog_post_one),
                 weblog_post: { publication_start_date_day: date.strftime("%d-%m-%Y"), publication_start_date_time: date.strftime("%H:%M") }

    assert_response :success
    assert_equal Time.local(date.year, date.month, date.day, date.hour, date.min), assigns(:weblog_post).publication_start_date
  end
end
