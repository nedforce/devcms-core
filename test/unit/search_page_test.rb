require File.dirname(__FILE__) + '/../test_helper'

class SearchPageTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  def test_should_create_search_page
    assert_difference('SearchPage.count') do
      sp = create_search_page
      assert !sp.new_record?, sp.errors.full_messages
    end
  end

  def test_should_require_title
    assert_no_difference 'SearchPage.count' do
      sp = create_search_page(:title => nil)
      assert sp.errors.on(:title)
    end
  end

  protected

  def create_search_page(options = {})
    SearchPage.create({:parent => nodes(:root_section_node), :title => 'Search test page' }.merge(options))
  end
end
