require File.dirname(__FILE__) + '/../test_helper'

class NewsletterEditionTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true
  
  def setup
    @root_node = nodes(:root_section_node)
    @devcms_newsletter_archive = newsletter_archives(:devcms_newsletter_archive)
    @devcms_newsletter_edition = newsletter_editions(:devcms_newsletter_edition)
  end
  
  def test_should_create_newsletter_edition
    assert_difference 'NewsletterEdition.count' do
      ne = create_newsletter_edition
      assert ne.valid?
    end
  end

  def test_should_require_title
    assert_no_difference 'NewsletterEdition.count' do
      newsletter_edition = create_newsletter_edition(:title => nil)
      assert newsletter_edition.errors.on(:title)
    end
    
    assert_no_difference 'NewsletterEdition.count' do
      newsletter_edition = create_newsletter_edition(:title => "  ")
      assert newsletter_edition.errors.on(:title)
    end
  end

  def test_should_require_body
    assert_no_difference 'NewsletterEdition.count' do
      newsletter_edition = create_newsletter_edition(:body => nil)
      assert newsletter_edition.errors.on(:body)
    end
  end
  
  def test_should_require_parent
    assert_no_difference 'NewsletterEdition.count' do
      newsletter_edition = create_newsletter_edition(:parent => nil)
      assert newsletter_edition.errors.on(:newsletter_archive)
    end
  end

  def test_should_not_require_unique_title
    assert_difference 'NewsletterEdition.count', 2 do
      2.times do
        newsletter_edition = create_newsletter_edition(:title => 'Non-unique title')
        assert !newsletter_edition.errors.on(:title)
      end
    end
  end
  
  def test_should_update_newsletter_edition
    assert_no_difference 'NewsletterEdition.count' do
      @devcms_newsletter_edition.title = 'New title'
      @devcms_newsletter_edition.body = 'New body'
      assert @devcms_newsletter_edition.save_for_user(users(:arthur))
    end
  end
  
  def test_should_destroy_newsletter_edition
    assert_difference "NewsletterEdition.count", -1 do
      @devcms_newsletter_edition.destroy
    end
  end
  
  def test_human_name_does_not_return_nil
    assert_not_nil NewsletterEdition.human_name 
  end
  
  def test_should_add_pages_and_news_item_nodes
    @devcms_newsletter_edition.associate_items([ nodes(:help_page_node).id, nodes(:devcms_news_item_node).id, nodes(:devcms_news_item_voor_vorige_maand_node).id])
    assert_equal 3, @devcms_newsletter_edition.items_count
  end
  
  def test_should_not_allow_duplicate_items
    newsletter_edition = create_newsletter_edition
    node_id = nodes(:about_page_node).id
    newsletter_edition.associate_items([node_id, node_id])
    assert_equal 1, newsletter_edition.items_count
  end

  def test_url_alias_for_news_item_with_publication_start_date
    start_date = 2.days.ago
    ne = create_newsletter_edition(:publication_start_date => start_date)
    assert_equal "gemeente-nieuwsbrief/#{start_date.year}/#{start_date.month}/#{start_date.day}/het-maandelijkse-nieuws-uit-nederland", ne.node.url_alias
  end

  def test_url_alias_for_news_item_without_specified_publication_start_date
    ne = create_newsletter_edition
    created_at = ne.created_at
    assert_equal "gemeente-nieuwsbrief/#{created_at.year}/#{created_at.month}/#{created_at.day}/het-maandelijkse-nieuws-uit-nederland", ne.node.url_alias
  end

  def test_tree_text_for_news_item_with_publication_start_date
    start_date = 2.days.ago
    ne = create_newsletter_edition(:publication_start_date => start_date)
    assert_equal "#{start_date.day}/#{start_date.month} #{ne.title}", ne.node.tree_text
  end

  def test_tree_text_for_news_item_without_specified_publication_start_date
    ne = create_newsletter_edition
    created_at = ne.created_at
    assert_equal "#{created_at.day}/#{created_at.month} #{ne.title}", ne.node.tree_text
  end
  
protected
  
  def create_newsletter_edition(options = {})
    NewsletterEdition.create({:parent => nodes(:newsletter_archive_node), :title => "Het maandelijkse nieuws uit Nederland!", :body => "O o o wat is het weer een fijne maand geweest." }.merge(options))
  end
end