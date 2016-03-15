require File.expand_path('../../test_helper.rb', __FILE__)

class ForumThreadTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  setup do
    @bewoners_forum_topic_wonen = forum_topics(:bewoners_forum_topic_wonen)
    @bewoners_forum_thread_one  = forum_threads(:bewoners_forum_thread_one)
    @jan                        = users(:jan)
  end

  def test_should_create_forum_thread
    assert_difference 'ForumThread.count' do
      create_forum_thread
    end
  end

  def test_should_require_user
    assert_no_difference 'ForumThread.count' do
      forum_thread = create_forum_thread(:user => nil)
      assert forum_thread.errors[:user].any?
    end
  end

  def test_should_require_forum_topic
    assert_no_difference 'ForumThread.count' do
      forum_thread = create_forum_thread(:forum_topic => nil)
      assert forum_thread.errors[:forum_topic].any?
    end
  end

  def test_should_require_title
    assert_no_difference 'ForumThread.count' do
      forum_thread = create_forum_thread(:title => nil)
      assert forum_thread.errors[:title].any?
    end

    assert_no_difference 'ForumThread.count' do
      forum_thread = create_forum_thread(:title => '   ')
      assert forum_thread.errors[:title].any?
    end
  end

  def test_should_update_forum_thread
    assert_no_difference 'ForumThread.count' do
      @bewoners_forum_thread_one.title = 'New title'
      assert @bewoners_forum_thread_one.save
    end
  end

  def test_should_destroy_forum_thread
    assert_difference 'ForumThread.count', -1 do
      @bewoners_forum_thread_one.destroy
    end
  end

  def test_is_owned_by_user?
    users = User.all

    ForumThread.all.each do |forum_thread|
      users.each do |user|
        if user == forum_thread.user
          assert forum_thread.is_owned_by_user?(user)
        else
          assert !forum_thread.is_owned_by_user?(user)
        end
      end
    end
  end

  def test_last_update_date_should_return_creation_date_of_last_created_forum_post
    post = @bewoners_forum_thread_one.forum_posts.create(:body => 'foobar', :user => users(:henk), :created_at => 4.hours.from_now)
    @bewoners_forum_thread_one.forum_posts.create(       :body => 'foobar', :user => users(:henk), :created_at => 3.hours.from_now)
    @bewoners_forum_thread_one.forum_posts.create(       :body => 'foobar', :user => users(:henk), :created_at => 2.hours.from_now)
    assert_equal post.reload.created_at, @bewoners_forum_thread_one.last_update_date
  end

  def test_should_close_open_thread
    assert @bewoners_forum_thread_one.close
    assert @bewoners_forum_thread_one.closed?
  end

  def test_should_open_closed_thread
    assert  @bewoners_forum_thread_one.close
    assert  @bewoners_forum_thread_one.open
    assert !@bewoners_forum_thread_one.closed?
  end

  def test_should_not_close_closed_thread
    assert  @bewoners_forum_thread_one.close
    assert !@bewoners_forum_thread_one.close
    assert  @bewoners_forum_thread_one.reload.closed?
  end

  def test_should_not_open_open_thread
    assert !@bewoners_forum_thread_one.open
    assert !@bewoners_forum_thread_one.reload.closed?
  end

  def test_start_post_should_return_first_created_post
    forum_threads = ForumThread.all

    forum_threads.each do |thread|
      assert_equal thread.start_post, thread.forum_posts.order(created_at: :asc).first
    end
  end

  def test_replies_should_return_all_posts_except_start_post
    forum_threads = ForumThread.all

    forum_threads.each do |thread|
      replies = thread.replies
      assert_equal((thread.forum_posts.size - 1), replies.size)
      assert !replies.include?(thread.start_post)
    end
  end

  def test_number_of_replies
    forum_threads = ForumThread.all

    forum_threads.each do |thread|
      assert_equal thread.replies.size, thread.number_of_replies
    end
  end

  protected

  def create_forum_thread(options = {})
    ForumThread.create({ :forum_topic => @bewoners_forum_topic_wonen, :user => @jan, :title => 'DevCMS forum threads, the best there are!' }.merge(options))
  end
end
