require File.expand_path('../../test_helper.rb', __FILE__)

class ForumPostTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  setup do
    @bewoners_forum_thread_one = forum_threads(:bewoners_forum_thread_one)
    @bewoners_forum_post_one   = forum_posts(:bewoners_forum_post_one)
    @jan                       = users(:jan)
    @arthur                    = users(:arthur)
  end

  test 'should create forum post' do
    assert_difference 'ForumPost.count' do
      create_forum_post
    end
  end

  test 'should not destroy start post' do
    assert_no_difference 'ForumPost.count' do
      refute @bewoners_forum_post_one.destroy
    end
    assert_equal 5, @bewoners_forum_thread_one.forum_posts.size
    assert_not_nil @bewoners_forum_thread_one.start_post
    assert_equal @bewoners_forum_post_one, @bewoners_forum_thread_one.start_post
  end

  test 'should require user' do
    assert_no_difference 'ForumPost.count' do
      forum_post = create_forum_post(user: nil)
      assert forum_post.errors[:user].any?
    end
  end

  test 'user should take precedence over user name' do
    forum_post = create_forum_post(user: @jan, user_name: 'Blaat')
    assert_equal @jan.login, forum_post.user_name
  end

  test 'should require forum thread' do
    assert_no_difference 'ForumPost.count' do
      forum_post = create_forum_post(forum_thread: nil)
      assert forum_post.errors[:forum_thread].any?
    end
  end

  test 'should require body' do
    assert_no_difference 'ForumPost.count' do
      forum_post = create_forum_post(body: nil)
      assert forum_post.errors[:body].any?
    end

    assert_no_difference 'ForumPost.count' do
      forum_post = create_forum_post(body: '  ')
      assert forum_post.errors[:body].any?
    end
  end

  test 'should not add post to closed thread' do
    @bewoners_forum_thread_one.close

    assert_no_difference 'ForumPost.count' do
      forum_post = create_forum_post
      assert forum_post.errors[:base].any?
    end

    @bewoners_forum_thread_one.open

    assert_difference 'ForumPost.count', 1 do
      forum_post = create_forum_post
      assert forum_post.errors[:base].empty?
    end
  end

  test 'should update forum post' do
    assert_no_difference 'ForumPost.count' do
      @bewoners_forum_post_one.body = 'New body'
      assert @bewoners_forum_post_one.save
    end
  end

  test 'should destroy forum post' do
    assert_difference 'ForumPost.count', -1 do
      forum_posts(:bewoners_forum_post_seven).destroy
    end
  end

  test 'should return whether it is owned by user' do
    users = User.all

    ForumPost.all.each do |forum_post|
      users.each do |user|
        if user == forum_post.user
          assert forum_post.is_owned_by_user?(user)
        else
          refute forum_post.is_owned_by_user?(user)
        end
      end
    end
  end

  test 'should return if it is a start post' do
    forum_threads = ForumThread.all

    forum_threads.each do |thread|
      assert thread.start_post.is_start_post?
      new_post = thread.forum_posts.create(body: 'foo', user: @jan)
      refute new_post.is_start_post?
    end
  end

  test 'should notify thread owner' do
    ActionMailer::Base.deliveries.clear

    create_forum_post

    assert_equal 1, ActionMailer::Base.deliveries.size
    email = ActionMailer::Base.deliveries.first
    body = email.parts.first.body

    assert email.to.include?(@bewoners_forum_thread_one.user.email_address)
    assert email.subject.include?('Nieuwe reactie op forum')

    assert body.include?('Enjoy!')
    assert body.include?(@jan.full_name)
  end

  test 'should not return start posts' do
    refute ForumPost.all.select(&:is_start_post?).empty?
    assert ForumPost.replies.select(&:is_start_post?).empty?
  end

  test 'should get and set body' do
    post = create_forum_post
    post.comment = 'Test'
    assert_equal 'Test', post.comment
    assert_equal 'Test', post.body
  end

  test 'should return editable comments' do
    assert_equal ForumPost.replies, ForumPost.editable_comments_for(@arthur)

    editable_forum_post     = create_forum_post(user: users(:final_editor))
    non_editable_forum_post = create_forum_post(forum_thread: forum_threads(:bewoners_forum_thread_three))

    editable_forum_posts = ForumPost.editable_comments_for(users(:final_editor))
    assert editable_forum_posts.include?(editable_forum_post)
    refute editable_forum_posts.include?(non_editable_forum_post)

    editable_forum_post  = create_forum_post(user: users(:editor))
    editable_forum_posts = ForumPost.editable_comments_for(users(:editor))

    assert editable_forum_posts.include?(editable_forum_post)
    refute editable_forum_posts.include?(non_editable_forum_post)
  end

  protected

  def create_forum_post(options = {})
    ForumPost.create({
      forum_thread: @bewoners_forum_thread_one,
      user: @jan,
      body: 'Enjoy!'
    }.merge(options))
  end
end
