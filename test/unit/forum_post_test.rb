require File.dirname(__FILE__) + '/../test_helper'

class ForumPostTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  def setup
    @bewoners_forum_thread_one = forum_threads(:bewoners_forum_thread_one)
    @bewoners_forum_post_one = forum_posts(:bewoners_forum_post_one)
    @jan = users(:jan)
  end

  def test_should_create_forum_post
    assert_difference 'ForumPost.count' do
      create_forum_post
    end
  end

  def test_should_not_destroy_start_post
    assert_no_difference "ForumPost.count" do
      @bewoners_forum_post_one.destroy
    end
    assert_equal 5, @bewoners_forum_thread_one.forum_posts.size
    assert_not_nil  @bewoners_forum_thread_one.start_post
    assert_equal @bewoners_forum_post_one, @bewoners_forum_thread_one.start_post
  end

   def test_should_require_user
    assert_no_difference 'ForumPost.count' do
      forum_post = create_forum_post(:user => nil)
      assert forum_post.errors.on(:user)
    end
  end

  def test_user_takes_precedence_over_user_name
    forum_post = create_forum_post(:user => @jan, :user_name => 'Blaat')
    assert_equal @jan.login, forum_post.user_name
  end

  def test_should_require_forum_thread
    assert_no_difference 'ForumPost.count' do
      forum_post = create_forum_post(:forum_thread => nil)
      assert forum_post.errors.on(:forum_thread)
    end
  end

  def test_should_require_body
    assert_no_difference 'ForumPost.count' do
      forum_post = create_forum_post(:body => nil)
      assert forum_post.errors.on(:body)
    end

    assert_no_difference 'ForumPost.count' do
      forum_post = create_forum_post(:body => "  ")
      assert forum_post.errors.on(:body)
    end
  end

  def test_should_not_add_post_to_closed_thread
    @bewoners_forum_thread_one.close

    assert_no_difference 'ForumPost.count' do
      forum_post = create_forum_post()
      assert forum_post.errors.on_base
    end

    @bewoners_forum_thread_one.open

    assert_difference 'ForumPost.count', 1 do
      forum_post = create_forum_post()
      assert_nil forum_post.errors.on_base
    end

  end

  def test_should_update_forum_post
    assert_no_difference 'ForumPost.count' do
      @bewoners_forum_post_one.body = 'New body'
      assert @bewoners_forum_post_one.save
    end
  end

  def test_should_destroy_forum_post
    assert_difference "ForumPost.count", -1 do
      forum_posts(:bewoners_forum_post_seven).destroy
    end
  end

  def test_is_owned_by_user?
    users = User.find(:all)

    ForumPost.find(:all).each do |forum_post|
      users.each do |user|
        if user == forum_post.user
          assert forum_post.is_owned_by_user?(user)
        else
          assert !forum_post.is_owned_by_user?(user)
        end
      end
    end
  end

  def test_is_start_post?
    forum_threads = ForumThread.find :all

    forum_threads.each do |thread|
      assert thread.start_post.is_start_post?
      new_post = thread.forum_posts.create(:body => 'foo', :user => @jan)
      assert !new_post.is_start_post?
    end
  end

  def test_should_notify_thread_owner
    ActionMailer::Base.deliveries.clear

    create_forum_post

    assert_equal 1, ActionMailer::Base.deliveries.size
    email = ActionMailer::Base.deliveries.first
    assert email.to.include?(@bewoners_forum_thread_one.user.email_address)
    assert email.subject.include?("Nieuwe reactie op forum")
    assert email.body.include?('Enjoy!')
    assert email.body.include?(@jan.full_name)
  end

  def test_should_not_return_start_posts
    assert !ForumPost.all.select{|fp| fp.is_start_post? }.empty?
    assert ForumPost.replies.select{|fp| fp.is_start_post? }.empty?
  end

  def test_should_get_and_set_body
    post = create_forum_post
    post.comment = 'Test'
    assert_equal 'Test', post.comment
    assert_equal 'Test', post.body
  end

  def test_should_return_editable_comments
    assert_equal ForumPost.replies, ForumPost.editable_comments_for(users(:arthur))

    editable_forum_post = create_forum_post(:user => users(:final_editor))
    non_editable_forum_post = create_forum_post(:forum_thread => forum_threads(:bewoners_forum_thread_three))

    editable_forum_posts = ForumPost.editable_comments_for(users(:final_editor))
    assert editable_forum_posts.include?(editable_forum_post)
    assert !editable_forum_posts.include?(non_editable_forum_post)

    editable_forum_post = create_forum_post(:user => users(:editor))
    editable_forum_posts = ForumPost.editable_comments_for(users(:editor))

    assert editable_forum_posts.include?(editable_forum_post)
    assert !editable_forum_posts.include?(non_editable_forum_post)
  end

protected

  def create_forum_post(options = {})
    ForumPost.create({ :forum_thread => @bewoners_forum_thread_one, :user => @jan, :body => "Enjoy!" }.merge(options))
  end
end

