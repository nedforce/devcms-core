require File.expand_path('../../test_helper.rb', __FILE__)

class NewsViewerArchiveTest < ActiveSupport::TestCase

  def setup
    @news_viewer = create_news_viewer
  end
      
  def test_should_validate_uniqueness
    @news_viewer.news_archives << news_archives(:devcms_news)    
    archive = @news_viewer.news_viewer_archives.create(:news_archive => news_archives(:devcms_news))    
    assert !archive.valid?
  end
  
  def test_should_create_news_viewer_items_on_create
    item1 = create_news_item
    item2 = create_news_item        
    old_item = create_news_item(:publication_start_date => 3.weeks.ago)
    
    @news_viewer.news_archives << news_archives(:devcms_news)    
    assert @news_viewer.news_items.include?(item1)
    assert @news_viewer.news_items.include?(item2)
    assert !@news_viewer.news_items.include?(old_item)
  end

  def test_should_destroy_news_viewer_items_on_destroy
    item1 = create_news_item
    item2 = create_news_item        

    archive = @news_viewer.news_viewer_archives.create(:news_archive => news_archives(:devcms_news))    
    assert @news_viewer.news_items.include?(item1)
    assert @news_viewer.news_items.include?(item2)
    
    assert archive.destroy
    assert !@news_viewer.news_items.include?(item1)
    assert !@news_viewer.news_items.include?(item2)    
  end

private

  def create_news_viewer(options = {})
    NewsViewer.create({ :parent => nodes(:root_section_node), :publication_start_date => 1.day.ago, :title => 'General NewsViewer', :description => 'Gecombineerd nieuws' }.merge(options))
  end

  def create_news_item(options = {})
    NewsItem.create({ :parent => nodes(:devcms_news_node), :publication_start_date => 1.day.ago, :title => 'Slecht weer!', :body => 'Het zonnetje schijnt niet en de mensen zijn ontevreden.' }.merge(options))
  end
end
