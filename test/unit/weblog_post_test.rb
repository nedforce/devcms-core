require File.dirname(__FILE__) + '/../test_helper'

class WeblogPostTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true
  
  def setup
    @henk_weblog = weblogs(:henk_weblog)
    @henk_weblog_post_one = weblog_posts(:henk_weblog_post_one)
  end
  
  def test_should_create_weblog_post
    assert_difference 'WeblogPost.count' do
      wp = create_weblog_post
    end
  end

  def test_should_require_title
    assert_no_difference 'WeblogPost.count' do
      weblog_post = create_weblog_post(:title => nil)
      assert weblog_post.errors.on(:title)
    end
    
    assert_no_difference 'WeblogPost.count' do
      weblog_post = create_weblog_post(:title => "  ")
      assert weblog_post.errors.on(:title)
    end
  end

  def test_should_require_body
    assert_no_difference 'WeblogPost.count' do
      weblog_post = create_weblog_post(:body => nil)
      assert weblog_post.errors.on(:body)
    end
  end
  
  def test_should_require_parent
    assert_no_difference 'WeblogPost.count' do
      weblog_post = create_weblog_post(:parent => nil)
      assert weblog_post.errors.on(:weblog)
    end
  end

  def test_should_not_require_unique_title
    assert_difference 'WeblogPost.count', 2 do
      2.times do
        weblog_post = create_weblog_post(:title => 'Non-unique title')
        assert !weblog_post.errors.on(:title)
      end
    end
  end
  
  def test_should_update_weblog_post
    assert_no_difference 'WeblogPost.count' do
      @henk_weblog_post_one.title = 'New title'
      @henk_weblog_post_one.body = 'New body'
      assert @henk_weblog_post_one.send(:save)
    end
  end
  
  def test_should_destroy_weblog_post
    assert_difference "WeblogPost.count", -1 do
      @henk_weblog_post_one.destroy
    end
  end
  
  def test_human_name_does_not_return_nil
    assert_not_nil WeblogPost.human_name 
  end
  
  def test_should_not_return_weblog_post_children_for_menu
    assert @henk_weblog.node.accessible_children(:for_menu => true).empty?
  end

  def test_url_alias_for_news_item_with_publication_start_date
    start_date = 2.days.ago
    wp = create_weblog_post(:publication_start_date => start_date)
    assert_equal "gemeente-weblogs/henk-weblog/#{start_date.year}/#{start_date.month}/#{start_date.day}/some-interesting-title", wp.reload.node.reload.url_alias
  end

  def test_url_alias_for_news_item_without_specified_publication_start_date
    wp = create_weblog_post
    created_at = wp.created_at
    assert_equal "gemeente-weblogs/henk-weblog/#{created_at.year}/#{created_at.month}/#{created_at.day}/some-interesting-title", wp.reload.node.reload.url_alias
  end

  def test_tree_text_for_news_item_with_publication_start_date
    start_date = 2.days.ago
    wp = create_weblog_post(:publication_start_date => start_date)
    assert_equal "#{start_date.day}/#{start_date.month} #{wp.title}", wp.node.tree_text
  end

  def test_tree_text_for_news_item_without_specified_publication_start_date
    wp = create_weblog_post
    created_at = wp.created_at
    assert_equal "#{created_at.day}/#{created_at.month} #{wp.title}", wp.node.tree_text
  end
  
protected
  
  def create_weblog_post(options = {})
    WeblogPost.create({:parent => @henk_weblog.node, :title => "Some interesting title.", :body => "Some interesting body." }.merge(options))
  end
end
