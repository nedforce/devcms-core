require File.dirname(__FILE__) + '/../test_helper'

class ImporterTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true
  
  def setup
    @root_section = sections(:root_section)
    @root_section_node = nodes(:root_section_node)
    
    @pages_spreadsheet_path = File.dirname(__FILE__) + '/../fixtures/files/pages.xlsx'
    @pages2_spreadsheet_path = File.dirname(__FILE__) + '/../fixtures/files/pages2.xlsx'
  end
  
  def test_should_create_content_instances_with_correct_types
    assert_difference 'Page.count', 7 do
      instances = Importer.import!(@pages_spreadsheet_path, @root_section)
      
      instances.each do |instance|
        assert !instance.new_record?
      end
    end
  end
  
  def test_should_create_default_content_type_instances_when_no_content_type_is_specified
    assert_difference "#{Importer::IMPORTABLE_CONTENT_TYPES[Importer::DEFAULT_TYPE][:type]}.count", 7 do
      instances = Importer.import!(@pages_spreadsheet_path, @root_section)
      
      instances.each do |instance|
        assert !instance.new_record?
      end
    end
  end
  
  def test_should_set_correct_content_type_attributes_on_import
    instances = Importer.import!(@pages_spreadsheet_path, @root_section)
    
    %w( foo bar baz quux mos henk def ).each_with_index do |title, index|
      assert_equal title, instances[index].title
    end
  end
  
  def test_should_set_correct_meta_attributes_on_import
    instances = Importer.import!(@pages_spreadsheet_path, @root_section)
    
    [ true, false, true, true, false, true, true ].each_with_index do |show_in_menu, index|
      assert_equal show_in_menu, instances[index].node.show_in_menu
    end
  end
  
  def test_should_create_nested_sections_as_required
    assert_difference 'Section.count', 4 do
      instances = Importer.import!(@pages_spreadsheet_path, @root_section)
    
      first_child_section = @root_section_node.children.sections.find_by_title('sectie 1')
      second_child_section = @root_section_node.children.sections.find_by_title('sectie')
      grand_child_section = first_child_section.children.sections.find_by_title('sectie 2')
      grand_grand_child_section = grand_child_section.children.sections.find_by_title('sectie 3')
    
      assert !first_child_section.new_record?
      assert !second_child_section.new_record?
      assert !grand_child_section.new_record?
      assert !grand_grand_child_section.new_record?
    
      [ @root_section_node, first_child_section, grand_child_section, @root_section_node, second_child_section, grand_child_section, grand_grand_child_section ].each_with_index do |section_node, index|
        assert_equal section_node, instances[index].node.parent
      end
    end
  end
  
end