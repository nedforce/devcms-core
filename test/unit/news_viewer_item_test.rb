require File.expand_path('../../test_helper.rb', __FILE__)

class NewsViewerItemTest < ActiveSupport::TestCase

  def setup
    @news_viewer = create_news_viewer
    @news_viewer_item = create_news_viewer_item
  end
      
  def test_should_validate_uniqueness
    item = create_news_viewer_item(:news_item => @news_viewer_item.news_item)    
    assert !item.valid?
  end

private

  def create_news_viewer_item(options = {})
    @news_viewer.news_viewer_items.create({ :news_item => create_news_item }.merge(options))    
  end

  def create_news_viewer(options = {})
    NewsViewer.create({ :parent => nodes(:root_section_node), :publication_start_date => 1.day.ago, :title => 'General NewsViewer', :description => 'Gecombineerd nieuws' }.merge(options))
  end

  def create_news_item(options = {})
    NewsItem.create({ :parent => nodes(:devcms_news_node), :publication_start_date => 1.day.ago, :title => 'Slecht weer!', :body => 'Het zonnetje schijnt niet en de mensen zijn ontevreden.' }.merge(options))
  end
end
