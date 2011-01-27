require File.dirname(__FILE__) + '/../test_helper'

class NewsletterArchiveTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true
  
  def setup
    @root_node = nodes(:root_section_node)
    @devcms_newsletter_archive = newsletter_archives(:devcms_newsletter_archive)
  end
  
  def test_should_create_newsletter_archive
    assert_difference 'NewsletterArchive.count' do
      create_newsletter_archive
    end
  end
  
  def test_should_return_header_file_names
    path = Rails.root.join('public', 'images', 'newsletter', "#{Settler[:newsletter_archive_header_prefix]}*")
    assert_equal Dir.glob(path).size, NewsletterArchive.header_images.size
  end
  
  def test_should_default_to_standard_header
    assert_equal @devcms_newsletter_archive.header, Settler[:newsletter_archive_header_default]
  end
  
  def test_should_require_title
    assert_no_difference 'NewsletterArchive.count' do
      newsletter_archive = create_newsletter_archive(:title => nil)
      assert newsletter_archive.errors.on(:title)
    end
    
    assert_no_difference 'NewsletterArchive.count' do
      newsletter_archive = create_newsletter_archive(:title => "  ")
      assert newsletter_archive.errors.on(:title)
    end
  end

  def test_should_not_require_unique_title
    assert_difference 'NewsletterArchive.count', 2 do
      2.times do
        newsletter_archive = create_newsletter_archive(:title => 'Non-unique title')
        assert !newsletter_archive.errors.on(:title)
      end
    end
  end
  
  def test_should_update_newsletter_archive
    assert_no_difference 'NewsletterArchive.count' do
      @devcms_newsletter_archive.title = 'New title'
      @devcms_newsletter_archive.description = 'New description'
      assert @devcms_newsletter_archive.send(:save)
    end
  end
  
  def test_should_destroy_newsletter_archive
    assert_difference "NewsletterArchive.count", -1 do
      @devcms_newsletter_archive.destroy
    end
  end
  
  def test_has_subscription_for?
    users = User.find(:all)
    
    NewsletterArchive.find(:all).each do |newsletter_archive|
      users.each do |user|
        if newsletter_archive.users.include?(user)
          assert newsletter_archive.has_subscription_for?(user)
        else
          assert !newsletter_archive.has_subscription_for?(user)
        end
      end
    end
  end
  
  def test_should_allow_optional_from_address
    @devcms_newsletter_archive.from_email_address = 'admin@devcms.nl'
    assert @devcms_newsletter_archive.send(:save)    
  end
  
  def test_should_validate_optional_from_address
    @devcms_newsletter_archive.from_email_address = 'no_email_address'
    @devcms_newsletter_archive.send(:save)
    assert @devcms_newsletter_archive.errors.on(:from_email_address)       
  end

  def test_find_years_with_newsletter_editions
    years = @devcms_newsletter_archive.newsletter_editions.map { |newsletter_edition|
      newsletter_edition.publication_start_date.year
    }.uniq

    assert @devcms_newsletter_archive.find_years_with_items.set_equals?(years)
  end

  def test_find_months_with_newsletter_editions_for_year
    year_month_pairs = @devcms_newsletter_archive.newsletter_editions.map { |newsletter_edition|
      [ newsletter_edition.publication_start_date.year, newsletter_edition.publication_start_date.month ]
    }.uniq

    year_month_pairs.each do |year_month_pair|
      year = year_month_pair.first
      assert year_month_pairs.select { |year_month_pair| year_month_pair.first == year }.map(&:last).flatten.uniq.set_equals?(@devcms_newsletter_archive.find_months_with_items_for_year(year))
    end
  end

  def test_find_all_newsletter_editions_for_month
    newsletter_editions = @devcms_newsletter_archive.newsletter_editions

    year_month_pairs = newsletter_editions.map { |newsletter_edition|
      [ newsletter_edition.publication_start_date.year, newsletter_edition.publication_start_date.month ]
    }.uniq

    year_month_pairs.each do |year_month_pair|
      year = year_month_pair.first
      month = year_month_pair.last
      found_newsletter_editions = @devcms_newsletter_archive.find_all_items_for_month(year, month)

      newsletter_editions.each do |newsletter_edition|
        if newsletter_edition.publication_start_date.year == year && newsletter_edition.publication_start_date.month == month
          assert found_newsletter_editions.include?(newsletter_edition)
        else
          assert !found_newsletter_editions.include?(newsletter_edition)
        end
      end
    end
  end

  def test_last_updated_at_should_return_updated_at_when_no_accessible_newsletter_editions_are_found
    nla = create_newsletter_archive
    assert_equal nla.updated_at, nla.last_updated_at(users(:arthur))
    nle1 = create_newsletter_edition nla, :published => 'published'
    nle1.node.update_attribute(:hidden, true)
    assert_equal nla.updated_at, nla.last_updated_at(users(:editor))
    nle2 = create_newsletter_edition nla, :publication_start_date => 1.day.from_now, :published => 'unpublished'
    assert_equal nla.updated_at, nla.last_updated_at(users(:editor))
  end

  def test_last_updated_at_should_return_publication_start_date_of_last_published_accessible_newsletter_edition
    nla = create_newsletter_archive

    nle1 = create_newsletter_edition(nla, :title => 'visible: 2 days ago, published', :publication_start_date => 2.days.ago)
    nle1.update_attribute :published, 'published'

    nle2 = create_newsletter_edition(nla, :title => 'hidden: 1 day ago, published', :publication_start_date => 1.day.ago)
    nle2.update_attribute :published, 'published'
    nle2.node.update_attribute(:hidden, true)

    nle3 = create_newsletter_edition(nla, :title => 'visible: 1 day ago, unpublished', :publication_start_date => 1.day.from_now)
    nle3.update_attribute :published, 'unpublished'
    
    assert_equal nle2.reload.publication_start_date, nla.last_updated_at(users(:arthur))
    assert_equal nle1.reload.publication_start_date.to_s, nla.last_updated_at(users(:editor)).to_s
  end
  
protected
  
  def create_newsletter_archive(options = {})
    NewsletterArchive.create({:parent => nodes(:root_section_node), :title => "Good news, everyone!", :description => "I'm sending you all on a highly controversial mission." }.merge(options))
  end

  def create_newsletter_edition(newsletter_archive, options = {})
    NewsletterEdition.create({:parent => newsletter_archive.node, :title => "Het maandelijkse nieuws!", :body => "O o o wat is het weer een fijne maand geweest.", :publication_start_date => Time.now + 1.minute }.merge(options))
  end
end
