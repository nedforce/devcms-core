require File.expand_path('../../test_helper.rb', __FILE__)

class SitemapsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  def setup
    @devcms_news = news_archives(:devcms_news)
  end

  test 'should show sitemap' do
    get :show
    assert_response :success
  end

  test 'should get changes atom' do
    get :changes, format: 'atom'
    assert_response :success
  end

  test 'should get changes atom when there is a future news item' do
    create_news_item(publication_start_date: 2.days.from_now)
    get :changes, format: 'atom'
    assert_response :success
  end

  test 'should get changes atom when there is a past news item' do
    create_news_item(publication_start_date: 2.days.ago, publication_end_date: 1.day.ago)
    get :changes, format: 'atom'
    assert_response :success
  end

  test 'should not contain unpublished news items in atom' do
    create_news_item(publication_start_date: 2.days.ago, publication_end_date: 1.day.from_now, title: 'Beschikbaar')
    create_news_item(publication_start_date: 2.days.from_now,                                  title: 'Nog niet beschikbaar')
    create_news_item(publication_start_date: 2.days.ago, publication_end_date: 1.day.ago,      title: 'Niet meer beschikbaar')

    get :changes, format: 'atom'

    assert_response :success
    assert_nil(assigns(:nodes).reject! { |node| !node.content.respond_to?(:title) || node.content.title == 'Nog niet beschikbaar' }, 'Not yet published items should not be shown')
    assert_nil(assigns(:nodes).reject! { |node| !node.content.respond_to?(:title) || node.content.title == 'Niet meer beschikbaar' }, 'No longer published items should not be shown')
    assert_not_nil(assigns(:nodes).reject! { |node| !node.content.respond_to?(:title) || node.content.title == 'Beschikbaar' }, 'Published items should not have been deleted')
  end

  test 'should not contain feeds in atom' do
    get :changes, format: 'atom'
    assert_response :success
    assert !assigns(:nodes).map(&:content_type).include?('Feed')
  end

  test 'should not contain hidden content in atom' do
    get :changes, format: 'atom'
    assert_response :success
    assert_nil assigns(:nodes).reject! { |n| !n.visible? }
  end

  test 'should get changes rss' do
    get :changes, format: 'rss'
    assert_response :success
  end

  test 'should get changes rss when there is a future news item' do
    create_news_item(publication_start_date: 2.days.from_now)
    get :changes, format: 'rss'
    assert_response :success
  end

  test 'should get changes rss when there is a past news item' do
    create_news_item(publication_start_date: 2.days.ago, publication_end_date: 1.day.ago)
    get :changes, format: 'rss'
    assert_response :success
  end

  test 'should not contain unpublished news items in rss' do
    create_news_item(publication_start_date: 2.days.ago, publication_end_date: 1.day.from_now, title: 'Beschikbaar')
    create_news_item(publication_start_date: 2.days.from_now,                                  title: 'Nog niet beschikbaar')
    create_news_item(publication_start_date: 2.days.ago, publication_end_date: 1.day.ago,      title: 'Niet meer beschikbaar')

    get :changes, format: 'rss'

    assert_response :success
    assert_nil(assigns(:nodes).reject! { |node| !node.content.respond_to?(:title) || node.content.title == 'Nog niet beschikbaar' }, 'Not yet published items should not be shown')
    assert_nil(assigns(:nodes).reject! { |node| !node.content.respond_to?(:title) || node.content.title == 'Niet meer beschikbaar' }, 'No longer published items should not be shown')
    assert_not_nil(assigns(:nodes).reject! { |node| !node.content.respond_to?(:title) || node.content.title == 'Beschikbaar' }, 'Published items should not have been deleted')
  end

  test 'should not contain feeds in rss' do
    get :changes, format: 'rss'
    assert_response :success
    assert !assigns(:nodes).map(&:content_type).include?('Feed')
  end

  test 'should not contain hidden content in rss' do
    get :changes, format: 'rss'
    assert_response :success
    assert_nil assigns(:nodes).reject! { |n| !n.visible? }
  end

  test 'should get changes since interval' do
    sleep 3
    Node.root.touch
    get :changes, format: 'xml', interval: 2.second.to_i
    assert assigns(:changes).include?(Node.root)
    assert_response :success
  end

  protected

  def create_news_item(options = {})
    NewsItem.create({
      parent: nodes(:devcms_news_node),
      title: 'Slecht weer!',
      body: 'Het zonnetje schijnt niet en de mensen zijn ontevreden.'
    }.merge(options))
  end
end
