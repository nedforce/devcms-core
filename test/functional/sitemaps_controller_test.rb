require File.dirname(__FILE__) + '/../test_helper'

class SitemapsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  def setup
    @devcms_news = news_archives(:devcms_news)
  end

  def test_should_show_sitemap
    get :show
    assert_response :success
  end

  def test_should_get_changes_atom
    get :changes, :format => 'atom'
    assert_response :success
  end

  def test_should_get_changes_atom_when_there_is_a_future_news_item
    create_news_item(:publication_start_date => 2.days.from_now)
    get :changes, :format => 'atom'
    assert_response :success
  end

  def test_should_get_changes_atom_when_there_is_a_past_news_item
    create_news_item(:publication_start_date => 2.days.ago, :publication_end_date => 1.day.ago)
    get :changes, :format => 'atom'
    assert_response :success
  end
  
  def test_should_not_contain_unpublished_news_items
    create_news_item(:publication_start_date => 2.days.ago, :publication_end_date => 1.day.from_now, :title => "Beschikbaar")
    create_news_item(:publication_start_date => 2.days.from_now, :title => "Nog niet beschikbaar")
    create_news_item(:publication_start_date => 2.days.ago, :publication_end_date => 1.day.ago, :title => "Niet meer beschikbaar")
    get :changes, :format => 'atom'
    assert_response :success
    assert_nil(assigns(:nodes).reject! { |node| !node.content.respond_to?(:title) || node.content.title == "Nog niet beschikbaar" }, "Not yet published items should not be shown")
    assert_nil(assigns(:nodes).reject! { |node| !node.content.respond_to?(:title) || node.content.title == "Niet meer beschikbaar" }, "No longer published items should not be shown")
    assert_not_nil(assigns(:nodes).reject! { |node| !node.content.respond_to?(:title) || node.content.title == "Beschikbaar" }, "Published items should not have been deleted")
  end
  
  def test_should_not_contain_feeds
    get :changes, :format => 'atom'
    assert_response :success
    assert !assigns(:nodes).map(&:content_type).include?("Feed")
  end

  def test_should_not_contain_hidden_content
    get :changes, :format => 'atom'
    assert_response :success
    assert_nil assigns(:nodes).reject! { |n| !n.visible? }
  end
  
  def test_should_get_changes_since_interval
    sleep 3
    Node.root.touch
    get :changes, :format => 'xml', :interval => 2.second.to_i
    assert assigns(:changes).include?(Node.root)
    assert_response :success
  end

protected

  def create_news_item(options = {})
    NewsItem.create({:parent => nodes(:devcms_news_node), :title => "Slecht weer!", :body => "Het zonnetje schijnt niet en de mensen zijn ontevreden."}.merge(options))
  end

end
