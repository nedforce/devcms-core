require File.dirname(__FILE__) + '/../test_helper'

class WeblogTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  def setup
    @devcms_weblog_archive  = weblog_archives(:devcms_weblog_archive)
    @example_weblog_archive = weblog_archives(:example_weblog_archive)
    @henk_weblog            = weblogs(:henk_weblog)
  end

  def test_should_create_weblog
    assert_difference 'Weblog.count' do
      create_weblog
    end
  end

  def test_should_require_title
    assert_no_difference 'Weblog.count' do
      weblog = create_weblog(:title => nil)
      assert weblog.errors.on(:title)
    end

    assert_no_difference 'Weblog.count' do
      weblog = create_weblog(:title => "  ")
      assert weblog.errors.on(:title)
    end
  end

  def test_should_require_parent
    assert_no_difference 'Weblog.count' do
      weblog = create_weblog(:parent => nil)
      assert weblog.errors.on(:weblog_archive)
    end
  end

  def test_should_require_user
    assert_no_difference 'Weblog.count' do
      weblog = create_weblog(:user => nil)
      assert weblog.errors.on(:user)
    end
  end

  def test_should_update_weblog
    assert_no_difference 'Weblog.count' do
      @henk_weblog.title       = 'New title'
      @henk_weblog.description = 'New description'
      assert @henk_weblog.send(:save)
    end
  end

  def test_should_destroy_weblog
    assert_difference "Weblog.count", -1 do
      @henk_weblog.destroy
    end
  end

  def test_human_name_does_not_return_nil
    assert_not_nil Weblog.human_name 
  end

  def test_should_not_return_weblog_children_for_menu
    assert @devcms_weblog_archive.node.accessible_children(:for_menu => true).empty?
  end

  def test_is_owned_by_user?
    users = User.all

    Weblog.all.each do |weblog|
      users.each do |user|
        if user == weblog.user
          assert weblog.is_owned_by_user?(user)
        else
          assert !weblog.is_owned_by_user?(user)
        end
      end
    end
  end

  def test_find_years_with_weblog_posts
    years = @henk_weblog.weblog_posts.map { |weblog_post|
      weblog_post.publication_start_date.year
    }.uniq

    assert @henk_weblog.find_years_with_items.set_equals?(years)
  end

  def test_find_months_with_weblog_posts_for_year
    year_month_pairs = @henk_weblog.weblog_posts.map { |weblog_post|
      [ weblog_post.publication_start_date.year, weblog_post.publication_start_date.month ]
    }.uniq

    year_month_pairs.each do |year_month_pair|
      year = year_month_pair.first
      assert year_month_pairs.select { |year_month_pair| year_month_pair.first == year }.map(&:last).flatten.uniq.set_equals?(@henk_weblog.find_months_with_items_for_year(year))
    end
  end

  def test_find_all_weblog_posts_for_month
    weblog_posts = @henk_weblog.weblog_posts

    year_month_pairs = weblog_posts.map { |weblog_post|
      [ weblog_post.publication_start_date.year, weblog_post.publication_start_date.month ]
    }.uniq

    year_month_pairs.each do |year_month_pair|
      year  = year_month_pair.first
      month = year_month_pair.last
      found_weblog_posts = @henk_weblog.find_all_items_for_month(year, month)

      weblog_posts.each do |weblog_post|
        if weblog_post.publication_start_date.year == year && weblog_post.publication_start_date.month == month
          assert found_weblog_posts.include?(weblog_post)
        else
          assert !found_weblog_posts.include?(weblog_post)
        end
      end
    end
  end

  def test_should_create_new_weblog_post_through_association
    w = create_weblog

    assert_nothing_raised do
      w.weblog_posts.create!(:parent => @henk_weblog.node, :body => 'foobar', :title => 'bar', :publication_start_date => Time.now)
    end  
  end

  def test_find_last_published_weblog_posts
    w = create_weblog

    3.times do |i|
      w.weblog_posts.create!(:parent => @henk_weblog.node, :body => 'foobar', :title => 'bar', :publication_start_date => Time.now - i.hours)
    end

    [ -1, 0, 2, 4 ].each do |limit|
      found_weblog_posts = w.find_last_published_weblog_posts(users(:arthur), limit)

      if limit <= 0
        assert found_weblog_posts.empty?
      else
        assert found_weblog_posts.size <= limit
        
        i = 0;
    
        while i < (found_weblog_posts.size - 1)
          assert found_weblog_posts[i].publication_start_date >= found_weblog_posts[i + 1].publication_start_date
          i = i + 1
        end
      end
    end
  end

  def test_last_updated_at_should_return_updated_at_when_no_accessible_weblog_posts_are_found
    w = create_weblog
    assert_equal w.updated_at, w.last_updated_at(users(:arthur))
    wp = create_weblog_post w
    wp.node.update_attribute(:hidden, true)
    assert_equal w.updated_at, w.last_updated_at(users(:editor))
  end

  def test_last_updated_at_should_return_publication_start_date_of_last_published_accessible_weblog_post
    w = create_weblog

    wp1 = create_weblog_post w, :publication_start_date => 2.days.ago

    wp2 = create_weblog_post w, :publication_start_date => 1.day.ago
    wp2.node.update_attribute(:hidden, true)

    wp3 = create_weblog_post w, :publication_start_date => 1.day.from_now

    assert_equal wp2.publication_start_date.to_s, w.last_updated_at(users(:arthur)).to_s
    assert_equal wp1.publication_start_date.to_s, w.last_updated_at(users(:editor)).to_s
  end
  
protected
  
  def create_weblog(options = {})
    Weblog.create({:parent => @devcms_weblog_archive.node, :user => users(:gerjan), :title => "Uitermate interessante weblog", :description => "Beschrijving komt hier." }.merge(options))
  end

  def create_weblog_post(weblog, options = {})
    WeblogPost.create({:parent => weblog.node, :title => "Some interesting title.", :body => "Some interesting body." }.merge(options))
  end
end