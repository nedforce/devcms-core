require File.expand_path('../../test_helper.rb', __FILE__)

# Unit tests for the +SearchPage+ model.
class SearchPageTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  test 'should create search page' do
    assert_difference('SearchPage.count') do
      sp = create_search_page
      assert !sp.new_record?, sp.errors.full_messages.to_sentence
    end
  end

  test 'should require title' do
    assert_no_difference 'SearchPage.count' do
      sp = create_search_page(title: nil)
      assert sp.errors[:title].any?
    end
  end

  protected

  def create_search_page(options = {})
    SearchPage.create({
      parent: nodes(:root_section_node),
      title: 'Search test page'
    }.merge(options))
  end
end
