require File.expand_path('../../test_helper.rb', __FILE__)

# Unit tests for the +TopHitsPage+ model.
class TopHitsPageTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  setup do
    @root_node    = nodes(:root_section_node)
    @top_ten_page = top_hits_pages(:top_ten_page)
  end

  def test_should_create_top_hits_page
    assert_difference 'TopHitsPage.count' do
      create_top_hits_page
    end
  end

  test 'should require title' do
    assert_no_difference 'TopHitsPage.count' do
      top_hits_page = create_top_hits_page(title: nil)
      assert top_hits_page.errors[:title].any?
    end

    assert_no_difference 'TopHitsPage.count' do
      top_hits_page = create_top_hits_page(title: '  ')
      assert top_hits_page.errors[:title].any?
    end
  end

  def test_should_not_require_unique_title
    assert_difference 'TopHitsPage.count', 2 do
      2.times do
        top_hits_page = create_top_hits_page(title: 'Non-unique title')
        refute top_hits_page.errors[:title].any?
      end
    end
  end

  def test_should_update_top_hits_page
    assert_no_difference 'TopHitsPage.count' do
      @top_ten_page.title = 'New title'
      assert @top_ten_page.save
      assert_equal 'New title', @top_ten_page.reload.title
    end
  end

  def test_should_destroy_top_hits_page
    assert_difference 'TopHitsPage.count', -1 do
      @top_ten_page.destroy
    end
  end

  def test_find_top_hits_should_not_include_content_from_disjoint_site
    top_hits_page = create_top_hits_page(parent: nodes(:sub_site_section_node))
    page_node = create_page(parent: nodes(:root_section_node)).node
    page_node.update_attribute(:hits, 3000)

    found_top_hits = top_hits_page.find_top_hits

    refute found_top_hits.include?(page_node)
  end

  def test_find_top_hits_should_not_include_hidden_content_for_user_without_proper_privileges
    page_node = create_page.node
    page_node.update_attribute(:hidden, true)
    page_node.update_attribute(:hits, 3000)

    found_top_hits = @top_ten_page.find_top_hits

    refute found_top_hits.include?(page_node)
  end

  def test_find_top_hits_should_not_include_excluded_content_types
    excluded_content_types = create_excluded_content_types

    excluded_content_types.each do |excluded_content_type|
      excluded_content_type.node.update_attribute(:hits, 100_000)
    end

    found_top_hits = @top_ten_page.find_top_hits(limit: excluded_content_types.size).map(&:content)

    excluded_content_types.each do |excluded_content_type|
      refute found_top_hits.include?(excluded_content_type), "a content node of type #{excluded_content_type.class} was included in the top list"
    end
  end

  protected

  def create_top_hits_page(options = {})
    TopHitsPage.create({
      parent: @root_node,
      title: 'Top hits page'
    }.merge(options))
  end

  def create_page(options = {})
    Page.create({
      parent: @root_node,
      title: 'Page title',
      preamble: 'Ambule',
      body: 'Page body'
    }.merge(options))
  end

  def create_excluded_content_types
    [
                  Image.create(parent: nodes(:devcms_news_item_node), title: 'Dit is een image.', file: fixture_file_upload('files/test.jpg')),
               Calendar.create(parent: @root_node,                    title: 'New calendar',                             description: 'This is a new calendar.'),
       CombinedCalendar.create(parent: @root_node,                    title: 'New combined calendar',                    description: 'This is a new combined calendar.'),
            NewsArchive.create(parent: @root_node,                    title: 'Good news, everyone!',                     description: "I'm sending you all on a highly controversial mission."),
      NewsletterArchive.create(parent: @root_node,                    title: 'Good news, everyone!',                     description: "I'm sending you all on a highly controversial mission."),
                Section.create(parent: @root_node,                    title: 'new section',                              description: 'new description for section.'),
                  Forum.create(parent: @root_node,                    title: 'DevCMS forums, the best there are!',       description: 'Enjoy!'),
             ForumTopic.create(parent: nodes(:bewoners_forum_node),   title: 'DevCMS forum topics, the best there are!', description: 'Enjoy!')
    ]
  end
end
