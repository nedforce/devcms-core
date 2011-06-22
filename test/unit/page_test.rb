require File.dirname(__FILE__) + '/../test_helper'

class PageTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  def setup
    @root_node = nodes(:root_section_node)
    @about_page = pages(:about_page)
  end

  def test_should_create_page
    assert_difference 'Page.count' do
      create_page
    end
  end

  def test_should_require_title
    assert_no_difference 'Page.count' do
      page = create_page(:title => nil)
      assert page.errors.on(:title)
    end

    assert_no_difference 'Page.count' do
      page = create_page(:title => "  ")
      assert page.errors.on(:title)
    end
  end

  def test_should_require_body
    assert_no_difference 'Page.count' do
      page = create_page(:body => nil)
      assert page.errors.on(:body)
    end
  end

  def test_should_not_require_unique_title
    assert_difference 'Page.count', 2 do
      2.times do
        page = create_page(:title => 'Non-unique title')
        assert !page.errors.on(:title)
      end
    end
  end

  def test_should_update_page
    assert_no_difference 'Page.count' do
      @about_page.title = 'New title'
      @about_page.body = 'New body'
      assert @about_page.save_for_user(users(:arthur))
    end
  end

  def test_should_destroy_page
    assert_difference "Page.count", -1 do
      @about_page.destroy
    end
  end

  protected
    def create_page(options = {})
      Page.create({:parent => nodes(:root_section_node), :title => "Page title", :body => "Page body", :expires_on => 1.day.from_now.to_date }.merge(options))
    end
end

