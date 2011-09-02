require File.dirname(__FILE__) + '/../test_helper'

class NewsViewerTest < ActiveSupport::TestCase

  def setup
    @news_viewer = create_news_viewer
  end
  
  def test_should_create_news_viewer
    assert_difference 'NewsViewer.count' do
      assert_equal nodes(:root_section_node), create_news_viewer.node.parent
    end
  end

  def test_should_require_title
    assert_no_difference 'NewsViewer.count' do
      news_viewer = create_news_viewer(:title => nil)
      assert news_viewer.errors.on(:title)
    end

    assert_no_difference 'NewsViewer.count' do
      news_viewer = create_news_viewer(:title => "  ")
      assert news_viewer.errors.on(:title)
    end
  end
  
  def test_should_not_require_unique_title
    assert_difference 'NewsViewer.count', 2 do
      2.times do
        news_viewer = create_news_viewer(:title => 'Non-unique title')
        assert !news_viewer.errors.on(:title)
      end
    end
  end
  
  def test_should_destroy_news_viewer
    assert @news_viewer.valid? && !@news_viewer.new_record?

    assert_difference "NewsViewer.count", -1 do
      @news_viewer.destroy
    end
  end

  def test_should_have_linked_news_items
    assert @news_viewer.news_items.empty?
    5.times{ @news_viewer.news_items << create_news_item }
    assert_equal 5, @news_viewer.news_items.count
  end
  
  def test_should_get_accessible_news_items
    n1 = create_news_item
    n2 = create_news_item
    n2.node.update_attribute(:hidden, true)
    n3 = create_news_item    
    n3.node.update_attribute(:publishable, false)
    n4 = create_news_item :publication_start_date => 3.weeks.ago
    
    @news_viewer.news_viewer_items.create(:news_item => n1, :position => 0)
    @news_viewer.news_viewer_items.create(:news_item => n2, :position => 1)
    @news_viewer.news_viewer_items.create(:news_item => n3, :position => 2)
    @news_viewer.news_viewer_items.create(:news_item => n4, :position => 3)       

    @news_viewer.accessible_news_items.each{|ni| assert ni.publication_start_date >= 2.weeks.ago.beginning_of_day }
    assert_equal [n1], @news_viewer.accessible_news_items
  end  
  
  def test_should_order_by_position
    n1 = create_news_item
    n2 = create_news_item
    
    nvi1 = @news_viewer.news_viewer_items.create(:news_item => n1, :position => 0)
    nvi2 = @news_viewer.news_viewer_items.create(:news_item => n2, :position => 1)    
    
    assert_equal [n1, n2], @news_viewer.accessible_news_items
    
    nvi1.update_attribute(:position, 1)
    nvi2.update_attribute(:position, 0)    
    
    assert_equal [n2, n1], @news_viewer.accessible_news_items
  end
  
  def test_should_order_by_date
    n1 = create_news_item :publication_start_date => 1.day.ago
    n2 = create_news_item :publication_start_date => 2.days.ago
    
    @news_viewer.news_items << n1
    @news_viewer.news_items << n2
    
    assert_equal [n1, n2], @news_viewer.accessible_news_items
    
    n1.update_attribute(:publication_start_date, 2.days.ago)
    n2.update_attribute(:publication_start_date, 1.day.ago)    
    
    assert_equal [n2, n1], @news_viewer.accessible_news_items
  end  
  
  def test_last_updated_at_should_return_updated_at_when_no_accessible_news_items_are_found
    assert_equal @news_viewer.updated_at, @news_viewer.last_updated_at
    ni = create_news_item
    @news_viewer.news_items << ni
    ni.node.update_attribute(:hidden, true)
    
    assert_equal @news_viewer.updated_at, @news_viewer.last_updated_at
  end
  
  def test_should_destroy_associated_viewer_items_on_destroy
    5.times{ @news_viewer.news_items << create_news_item }
    @news_viewer.destroy
    assert NewsViewerItem.all.empty?   
  end
  
  def test_should_update_news_items
    news_item = create_news_item(:title => 'Add me!')
    
    @news_viewer.news_archives << news_archives(:devcms_news)
    (0..30).each{|n| @news_viewer.news_items << create_news_item(:publication_start_date => n.days.ago, :title => (n.days.ago >= 2.weeks.ago) ? 'Keep me!' : 'Remove me!') }
    
    assert_no_difference "NewsItem.count" do 
      NewsViewer.update_news_items
    end

    @news_viewer.news_items.each{|ni| assert ni.publication_start_date >= 2.weeks.ago.beginning_of_day }
    assert @news_viewer.news_items.include?(news_item)
  end
      

private

  def create_news_viewer(options = {})
    NewsViewer.create({:parent => nodes(:root_section_node), :publication_start_date => 1.day.ago, :title => "General NewsViewer", :description => "Gecombineerd nieuws"}.merge(options))    
  end
  
  def create_news_item(options = {})
    NewsItem.create({:parent => nodes(:devcms_news_node), :publication_start_date => 1.day.ago, :title => "Slecht weer!", :body => "Het zonnetje schijnt niet en de mensen zijn ontevreden." }.merge(options))
  end  

end
