require File.expand_path('../../test_helper.rb', __FILE__)

# Unit tests for the +Page+ model.
class PageTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  setup do
    @root_node = nodes(:root_section_node)
    @about_page = pages(:about_page)
  end

  test 'should create page' do
    assert_difference 'Page.count' do
      create_page
    end
  end

  test 'should require title' do
    assert_no_difference 'Page.count' do
      page = create_page(title: nil)
      assert page.errors[:title].any?

      page = create_page(title: '  ')
      assert page.errors[:title].any?
    end
  end

  test 'should require body' do
    assert_no_difference 'Page.count' do
      page = create_page(body: nil)
      assert page.errors[:body].any?
    end
  end

  test 'should not require unique title' do
    assert_difference 'Page.count', 2 do
      2.times do
        page = create_page(title: 'Non-unique title')
        refute page.errors[:title].any?
      end
    end
  end

  test 'should update page' do
    assert_no_difference 'Page.count' do
      @about_page.title = 'New title'
      @about_page.body = 'New body'
      assert @about_page.save(user: users(:arthur))
    end
  end

  test 'should destroy page' do
    assert_difference 'Page.count', -1 do
      @about_page.destroy
    end
  end

  protected

  def create_page(options = {})
    Page.create({
      parent: nodes(:root_section_node),
      title: 'Page title',
      body: 'Page body'
    }.merge(options))
  end
end
