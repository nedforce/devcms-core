require File.dirname(__FILE__) + '/../test_helper'

class NewsItemTest < ActiveSupport::TestCase
  def setup
    @devcms_news = news_archives(:devcms_news)
    @devcms_news_item = news_items(:devcms_news_item)
  end
  
  def test_should_create_news_item
    assert_difference 'NewsItem.count' do
      ni = create_news_item
      assert ni.valid?
    end
  end

  def test_should_require_title
    assert_no_difference 'NewsItem.count' do
      news_item = create_news_item(:title => nil)
      assert news_item.errors.on(:title)
    end
    
    assert_no_difference 'NewsItem.count' do
      news_item = create_news_item(:title => "   ")
      assert news_item.errors.on(:title)
    end
  end

  def test_should_require_body
    assert_no_difference 'NewsItem.count' do
      news_item = create_news_item(:body => nil)
      assert news_item.errors.on(:body)
    end
  end

  def test_should_require_parent
    assert_no_difference 'NewsItem.count' do
      news_item = create_news_item(:parent => nil)
      assert news_item.errors.on(:news_archive)
    end
  end

  def test_should_not_require_unique_title
    assert_difference 'NewsItem.count', 2 do
      2.times do
        news_item = create_news_item(:title => 'Non-unique title')
        assert !news_item.errors.on(:title)
      end
    end
  end
  
  def test_should_update_news_item
    assert_no_difference 'NewsItem.count' do
      @devcms_news_item.title = 'New title'
      @devcms_news_item.body = 'New body'
      assert @devcms_news_item.save(:user => users(:arthur))
    end
  end
  
  def test_should_destroy_news_item
    assert_difference "NewsItem.count", -1 do
      @devcms_news_item.destroy
    end
  end

  def test_human_name_does_not_return_nil
    assert_not_nil NewsItem.human_name 
  end

  def test_should_not_return_news_item_children_for_menu
    assert @devcms_news.node.accessible_children(:for_menu => true).empty?
  end
  
  def test_url_alias_for_news_item_with_publication_start_date
    start_date = 2.days.ago
    ni = create_news_item(:publication_start_date => start_date)
    assert_equal "#{start_date.year}/#{start_date.month}/#{start_date.day}/slecht-weer", ni.node.url_alias
  end

  def test_url_alias_for_news_item_without_specified_publication_start_date
    ni = create_news_item
    created_at = ni.created_at
    assert_equal "#{created_at.year}/#{created_at.month}/#{created_at.day}/slecht-weer", ni.node.url_alias
  end
  
  def test_tree_text_for_news_item_with_publication_start_date
    start_date = 2.days.ago
    ni = create_news_item(:publication_start_date => start_date)
    assert_equal "#{start_date.day}/#{start_date.month} #{ni.title}", ni.node.tree_text
  end

  def test_tree_text_for_news_item_without_specified_publication_start_date
    ni = create_news_item
    created_at = ni.created_at
    assert_equal "#{created_at.day}/#{created_at.month} #{ni.title}", ni.node.tree_text
  end
  
protected
  
  def create_news_item(options = {})
    NewsItem.create({:parent => nodes(:devcms_news_node), :title => "Slecht weer!", :body => "Het zonnetje schijnt niet en de mensen zijn ontevreden." }.merge(options))
  end
end
