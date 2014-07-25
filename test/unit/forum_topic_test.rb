require File.expand_path('../../test_helper.rb', __FILE__)

class ForumTopicTest < ActiveSupport::TestCase
  def setup
    @bewoners_forum = forums(:bewoners_forum)
    @bewoners_forum_topic_wonen = forum_topics(:bewoners_forum_topic_wonen)
  end
  
  def test_should_create_forum_topic
    assert_difference 'ForumTopic.count' do
      create_forum_topic
    end
  end
 
  def test_should_require_parent
    assert_no_difference 'ForumTopic.count' do
      forum_topic = create_forum_topic(:parent => nil)
      assert !forum_topic.valid?
    end
  end
  
  def test_should_require_title
    assert_no_difference 'ForumTopic.count' do
      forum_topic = create_forum_topic(:title => nil)
      assert forum_topic.errors[:title].any?
    end
  end

  def test_should_require_unique_title
    assert_no_difference 'ForumTopic.count' do
      forum_topic = create_forum_topic(:title => @bewoners_forum_topic_wonen.title)
      assert forum_topic.errors[:title].any?
    end
  end
  
  def test_should_require_description
    assert_no_difference 'ForumTopic.count' do
      forum_topic = create_forum_topic(:description => nil)
      assert forum_topic.errors[:description].any?
    end
  end
  
  def test_should_update_forum_topic
    assert_no_difference 'ForumTopic.count' do
      @bewoners_forum_topic_wonen.title = 'New title'
      @bewoners_forum_topic_wonen.description = 'New description'
      assert @bewoners_forum_topic_wonen.save
    end
  end
  
  def test_should_destroy_forum_topic
    assert_difference "ForumTopic.count", -1 do
      @bewoners_forum_topic_wonen.destroy
    end
  end
  
  def test_last_update_date_should_return_creation_date_for_empty_topic
    ft = create_forum_topic
    assert_equal ft.created_at, ft.last_update_date
  end
  
  def test_last_update_date_should_return_maximum_last_update_date_of_all_threads_for_non_empty_topic
    first_thread = @bewoners_forum_topic_wonen.forum_threads.create(:title => 'foobar', :user => users(:henk))
    post = first_thread.forum_posts.create(:body => 'bazquux', :user => users(:henk), :created_at => Time.now + 3.hour)
    second_thread = @bewoners_forum_topic_wonen.forum_threads.create(:title => 'foobar', :user => users(:henk))
    second_thread.forum_posts.create(:body => 'bazquux', :user => users(:henk), :created_at => Time.now + 2.hour)
    assert_equal post.reload.created_at, @bewoners_forum_topic_wonen.last_update_date
  end
  
  def test_forum_threads_by_last_update_date
    first_thread = @bewoners_forum_topic_wonen.forum_threads.create(:title => 'foobar', :user => users(:henk))
    first_thread.forum_posts.create(:body => 'bazquux', :user => users(:henk), :created_at => Time.now + 3.hour)
    second_thread = @bewoners_forum_topic_wonen.forum_threads.create(:title => 'foobar', :user => users(:henk))
    second_thread.forum_posts.create(:body => 'bazquux', :user => users(:henk), :created_at => Time.now + 2.hour)
    found_forum_threads = @bewoners_forum_topic_wonen.forum_threads_by_last_update_date

    assert @bewoners_forum_topic_wonen.forum_threads.map(&:id).set_equals?(found_forum_threads.map(&:id))
    
    i = 0;
    
    while i < (found_forum_threads.size - 1)
      assert found_forum_threads[i].last_update_date >= found_forum_threads[i + 1].last_update_date
      i = i + 1
    end
  end

protected

  def create_forum_topic(options = {})
    ForumTopic.create({ :parent => @bewoners_forum.node, :title => 'DevCMS forum topics, the best there are!', :description => 'Enjoy!' }.merge(options))
  end
end
