require File.dirname(__FILE__) + '/../test_helper'

class NewsArchiveTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  def setup
    @devcms_news = news_archives(:devcms_news)
    @devcms_news_item_voor_deze_maand = news_items(:devcms_news_item)
    @devcms_news_item_voor_vorige_maand = news_items(:devcms_news_item_voor_vorige_maand)
    @devcms_news_item_voor_vorig_jaar = news_items(:devcms_news_item_voor_vorig_jaar)
  end

  def test_should_create_news_archive
    assert_difference 'NewsArchive.count' do
      create_news_archive
    end
  end

  def test_should_require_title
    assert_no_difference 'NewsArchive.count' do
      news_archive = create_news_archive(:title => nil)
      assert news_archive.errors.on(:title)
    end

    assert_no_difference 'NewsArchive.count' do
      news_archive = create_news_archive(:title => "  ")
      assert news_archive.errors.on(:title)
    end
  end

  def test_should_not_require_unique_title
    assert_difference 'NewsArchive.count', 2 do
      2.times do
        news_archive = create_news_archive(:title => 'Non-unique title')
        assert !news_archive.errors.on(:title)
      end
    end
  end

  def test_should_update_news_archive
    assert_no_difference 'NewsArchive.count' do
      @devcms_news.title = 'New title'
      @devcms_news.description = 'New description'
      assert @devcms_news.send(:save)
    end
  end

  def test_should_destroy_news_archive
    assert_difference "NewsArchive.count", -1 do
      @devcms_news.destroy
    end
  end

  def test_find_years_with_news_items
    years = @devcms_news.news_items.map { |news_item|
      news_item.publication_start_date.year
    }.uniq

    assert @devcms_news.find_years_with_items.set_equals?(years)
  end

  def test_find_months_with_news_items_for_year
    year_month_pairs = @devcms_news.news_items.map { |news_item|
      [ news_item.publication_start_date.year, news_item.publication_start_date.month ]
    }.uniq

    year_month_pairs.each do |year_month_pair|
      year = year_month_pair.first
      assert year_month_pairs.select { |year_month_pair| year_month_pair.first == year }.map(&:last).flatten.uniq.set_equals?(@devcms_news.find_months_with_items_for_year(year))
    end
  end

  def test_find_all_news_items_for_month
    news_items = @devcms_news.news_items

    year_month_pairs = news_items.map { |news_item|
      [ news_item.publication_start_date.year, news_item.publication_start_date.month ]
    }.uniq

    year_month_pairs.each do |year_month_pair|
      year = year_month_pair.first
      month = year_month_pair.last
      found_news_items = @devcms_news.find_all_items_for_month(year, month)

      news_items.each do |news_item|
        if news_item.publication_start_date.year == year && news_item.publication_start_date.month == month
          assert found_news_items.include?(news_item)
        else
          assert !found_news_items.include?(news_item)
        end
      end
    end
  end

  def test_should_not_destroy_items_for_invalid_month
    @devcms_news_item_voor_vorig_jaar.node.update_attribute :publication_start_date, 1.year.ago.to_s(:db)
    assert_no_difference("NewsItem.count") do
      assert_raise ArgumentError do
        @devcms_news.destroy_items_for_year_or_month(2010, "kaas")
      end
    end
  end

  def test_should_destroy_all_items_for_year
    @devcms_news_item_voor_vorig_jaar.node.update_attribute :publication_start_date, 1.year.ago.to_s(:db)
    @devcms_news_item_voor_vorige_maand.node.update_attribute :publication_start_date, Date.today.to_s(:db)
    @devcms_news_item_voor_deze_maand.node.update_attribute :publication_start_date, Date.today.to_s(:db)
    assert_difference("NewsItem.count", -2) do
      @devcms_news.destroy_items_for_year_or_month(Time.now.year)
    end
    assert_raise ActiveRecord::RecordNotFound do
      @devcms_news_item_voor_vorige_maand.reload
    end
    assert @devcms_news_item_voor_vorig_jaar.reload
  end

  def test_should_destroy_all_items_for_month
    @devcms_news_item_voor_vorige_maand.node.update_attribute :publication_start_date, 1.month.ago.to_s(:db)
    @devcms_news_item_voor_deze_maand.node.update_attribute :publication_start_date, Date.today.to_s(:db)
    assert_difference("NewsItem.count", -1) do
      @devcms_news.destroy_items_for_year_or_month(Time.now.year, Time.now.month)
    end
    assert_raise ActiveRecord::RecordNotFound do
      @devcms_news_item_voor_deze_maand.reload
    end
    assert @devcms_news_item_voor_vorige_maand.reload
  end

  def test_last_updated_at_should_return_updated_at_when_no_accessible_news_items_are_found
    na = create_news_archive
    assert_equal na.updated_at, na.last_updated_at
    ni = create_news_item na
    ni.node.update_attribute(:hidden, true)
    assert_equal na.updated_at, na.last_updated_at
  end

protected

  def create_news_archive(options = {})
    NewsArchive.create({:parent => nodes(:root_section_node), :title => "Good news, everyone!", :description => "I'm sending you all on a highly controversial mission." }.merge(options))
  end

  def create_news_item(news_archive, options = {})
    NewsItem.create({:parent => news_archive.node, :title => "Slecht weer!", :body => "Het zonnetje schijnt niet en de mensen zijn ontevreden.", :publication_start_date => Time.now }.merge(options))
  end
end

