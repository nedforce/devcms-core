require File.expand_path('../../test_helper.rb', __FILE__)

class HtmlPageTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  def setup
    @root_node = nodes(:root_section_node)
    @about_html_page = html_pages(:about_html_page)
  end

  def test_should_create_html_page
    assert_difference 'HtmlPage.count' do
      create_html_page
    end
  end

  def test_should_require_title
    assert_no_difference 'HtmlPage.count' do
      html_page = create_html_page(:title => nil)
      assert html_page.errors[:title].any?
    end

    assert_no_difference 'HtmlPage.count' do
      html_page = create_html_page(:title => '  ')
      assert html_page.errors[:title].any?
    end
  end

  def test_should_require_body
    assert_no_difference 'HtmlPage.count' do
      html_page = create_html_page(:body => nil)
      assert html_page.errors[:body].any?
    end
  end

  def test_should_not_require_unique_title
    assert_difference 'HtmlPage.count', 2 do
      2.times do
        html_page = create_html_page(:title => 'Non-unique title')
        assert !html_page.errors[:title].any?
      end
    end
  end

  def test_should_update_html_page
    assert_no_difference 'HtmlPage.count' do
      @about_html_page.title = 'New title'
      @about_html_page.body = 'New body'
      assert @about_html_page.save
    end
  end

  def test_should_destroy_html_page
    assert_difference 'HtmlPage.count', -1 do
      @about_html_page.destroy
    end
  end

protected

  def create_html_page(options = {})
    HtmlPage.create({ :parent => nodes(:root_section_node), :title => 'HtmlPage title', :body => 'HtmlPage body' }.merge(options))
  end
end
