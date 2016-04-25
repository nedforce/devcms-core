require File.expand_path('../../test_helper.rb', __FILE__)

class AlphabeticIndexTest < ActiveSupport::TestCase
  test 'should create alphabetic index' do
    assert_difference 'AlphabeticIndex.count' do
      create_alphabetic_index
    end
  end

  test 'should require title' do
    assert_no_difference 'AlphabeticIndex.count' do
      ai = create_alphabetic_index(title: nil)
      assert ai.errors[:title].any?
    end
  end

  test 'should return descendants of parent node' do
    assert_equal [pages(:yet_another_page)], alphabetic_indices(:subsection_alphabetic_index).items('Y')
    assert_equal [pages(:yet_another_page)], alphabetic_indices(:subsection_alphabetic_index).items('y')
    assert_equal [], alphabetic_indices(:subsection_alphabetic_index).items('Q')
  end

  test 'should include title alternative tags' do
    pages(:yet_another_page).node.update_attributes title_alternative_list: 'Quarcks, Abnormality'
    assert_equal [pages(:yet_another_page)], alphabetic_indices(:subsection_alphabetic_index).items('q')
    assert_equal [pages(:yet_another_page)], alphabetic_indices(:subsection_alphabetic_index).items
  end

  test 'should order by title or tag' do
    # Page.create
    pages = alphabetic_indices(:root_alphabetic_index).items
    assert_equal pages.map { |p| p.title.upcase }, pages.map { |p| p.title.upcase }.sort

    page = Page.create title: 'Not with an A', body: '....', parent: nodes(:root_section_node), title_alternative_list: 'Alternative', expires_on: 1.day.from_now.to_date
    assert_equal page, alphabetic_indices(:root_alphabetic_index).items.last

    page.update_attributes title_alternative_list: 'A1ternative'
    assert_equal page, alphabetic_indices(:root_alphabetic_index).items.first
  end

  protected

  def create_alphabetic_index(options = {})
    AlphabeticIndex.create({
      parent: nodes(:root_section_node),
      title: 'Test index'
    }.merge(options))
  end
end
