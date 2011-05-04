require File.dirname(__FILE__) + '/../test_helper'

class AlphabeticIndexTest < ActiveSupport::TestCase

  def test_should_create_alphabetic_index
    assert_difference 'AlphabeticIndex.count' do
      create_alphabetic_index
    end
  end

  def test_should_require_title
    assert_no_difference 'AlphabeticIndex.count' do
      ai = create_alphabetic_index(:title => nil)
      assert ai.errors.on(:title)
    end
  end

  def test_should_return_descendants_of_parent_node
    assert_equal alphabetic_indices(:subsection_alphabetic_index).items('Y'), [pages(:yet_another_page)]
    assert_equal alphabetic_indices(:subsection_alphabetic_index).items('y'), [pages(:yet_another_page)]
    assert_equal alphabetic_indices(:subsection_alphabetic_index).items('Q'), []
  end
  
  def test_should_include_title_alternative_tags
    pages(:yet_another_page).node.update_attributes :title_alternative_list => "Quarcks, Abnormality"
    assert_equal alphabetic_indices(:subsection_alphabetic_index).items('q'), [pages(:yet_another_page)]
    assert_equal alphabetic_indices(:subsection_alphabetic_index).items(), [pages(:yet_another_page)]
  end
  
  def test_should_order_by_title_or_tag
    # Page.create
    pages = alphabetic_indices(:root_alphabetic_index).items
    assert_equal pages.collect {|p| p.title.upcase }, pages.collect {|p| p.title.upcase }.sort
    page = Page.create :title => "Not with an A", :body => "....", :parent => nodes(:root_section_node), :title_alternative_list => "Alternative"
    # pp page
    #     pp alphabetic_indices(:root_alphabetic_index).items
    assert_equal page, alphabetic_indices(:root_alphabetic_index).items.last
    page.update_attributes :title_alternative_list => "A1ternative"
    assert_equal page, alphabetic_indices(:root_alphabetic_index).items.first
  end

  protected

  def create_alphabetic_index(options = {})
    AlphabeticIndex.create({ :parent => nodes(:root_section_node), :title => 'Test index' }.merge(options))
  end
end
