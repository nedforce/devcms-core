require File.expand_path('../../test_helper.rb', __FILE__)

class ActsAsCommentableTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true
  
  def setup    
    @arthur      = users(:arthur)
    @news_item   = news_items(:devcms_news_item).node
    @weblog_post = weblog_posts(:henk_weblog_post_one).node
    @event       = events(:events_calendar_item_one).node
  end
  
  def test_should_add_comments    
    comment = new_comment    
    @news_item.add_comment comment
    assert_equal 1, @news_item.comments.size
    assert_equal @news_item, comment.commentable

    comment = new_comment    
    @weblog_post.add_comment comment
    assert_equal 1, @weblog_post.comments.size
    assert_equal @weblog_post, comment.commentable
    
    comment = new_comment 
    @event.add_comment comment
    assert_equal 1, @event.comments.size
    assert_equal @event, comment.commentable
    
    assert_equal 3, Comment.all(:conditions => { :user_id => @arthur.id }).size
  end
  
  def test_should_require_user_or_user_name
    comment = new_comment(:user => nil, :user_name => nil)
    @news_item.add_comment comment
    
    assert comment.errors[:user_name].any?
  end
  
  def test_should_require_non_empty_comment
    comment = new_comment(:comment => '')
    @news_item.add_comment comment
    
    assert comment.errors[:comment].any?
  end
    
  protected

  def new_comment(options = {})
    Comment.new({ :user => @arthur, :comment => "I don't like it!" }.merge(options))
  end
end
