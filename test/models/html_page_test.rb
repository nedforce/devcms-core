require File.expand_path('../../test_helper.rb', __FILE__)

# Unit tests for the +HtmlPage+ model.
class HtmlPageTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  setup do
    @root_node = nodes(:root_section_node)
    @about_html_page = html_pages(:about_html_page)
  end

  test 'should create html page' do
    assert_difference 'HtmlPage.count' do
      create_html_page
    end
  end

  test 'should require title' do
    assert_no_difference 'HtmlPage.count' do
      html_page = create_html_page(title: nil)
      assert html_page.errors[:title].any?

      html_page = create_html_page(title: '  ')
      assert html_page.errors[:title].any?
    end
  end

  test 'should require body' do
    assert_no_difference 'HtmlPage.count' do
      html_page = create_html_page(body: nil)
      assert html_page.errors[:body].any?
    end
  end

  test 'should not require unique title' do
    assert_difference 'HtmlPage.count', 2 do
      2.times do
        html_page = create_html_page(title: 'Non-unique title')
        refute html_page.errors[:title].any?
      end
    end
  end

  test 'should update html page' do
    assert_no_difference 'HtmlPage.count' do
      @about_html_page.title = 'New title'
      @about_html_page.body = 'New body'
      assert @about_html_page.save
    end
  end

  test 'should destroy html page' do
    assert_difference 'HtmlPage.count', -1 do
      @about_html_page.destroy
    end
  end

  protected

  def create_html_page(options = {})
    HtmlPage.create({
      parent: nodes(:root_section_node),
      title: 'HtmlPage title',
      body: 'HtmlPage body'
    }.merge(options))
  end
end
