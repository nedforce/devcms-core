require File.dirname(__FILE__) + '/../test_helper'

class RoleAssignmentTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true
  
  def test_should_create_role_assignment
    assert_difference 'RoleAssignment.count' do
      role_assignment = create_role_assignment
      assert !role_assignment.new_record?, "#{role_assignment.errors.full_messages.to_sentence}"
    end
  end
  
  def test_should_require_uniqueness
    create_role_assignment
    assert_no_difference 'RoleAssignment.count' do
      role_assignment = create_role_assignment
      assert "#{role_assignment.errors.full_messages.to_sentence}"
    end
  end
  
  def test_should_require_fixed_node_types
    [nodes(:test_image_two_node), nodes(:devcms_news_item_node), nodes(:events_calendar_item_one_node)].each do |node|
      assert_no_difference 'RoleAssignment.count' do
        role_assignment = create_role_assignment(:name => 'editor', :node => node)
       assert "#{role_assignment.errors.full_messages.to_sentence}"
     end
    end
    [nodes(:about_page_node), nodes(:devcms_news_node), nodes(:events_calendar_node)].each do |node|
      assert_difference 'RoleAssignment.count', 1 do
        role_assignment = create_role_assignment(:name => 'editor', :node => node, :user => users(:klaas))
       assert role_assignment.errors.empty?
     end
    end
  end

  def test_should_require_root_node_for_admin
    assert_no_difference 'RoleAssignment.count' do
      role_assignment = create_role_assignment(:name => 'admin', :node => nodes(:test_image_two_node))
      assert "#{role_assignment.errors.full_messages.to_sentence}"
    end
  end
  
  def test_should_require_no_inherited_roles
    assert_no_difference 'RoleAssignment.count' do
      role_assignment = create_role_assignment(:user => users(:arthur))
      assert "#{role_assignment.errors.full_messages.to_sentence}"
    end
  end
  
  def test_should_require_node
    assert_no_difference 'RoleAssignment.count' do
      role_assignment = create_role_assignment(:node => nil)
      assert role_assignment.errors.on(:node)
    end
  end
  
  def test_should_require_name
    assert_no_difference 'RoleAssignment.count' do
      role_assignment = create_role_assignment(:name => nil)
      assert role_assignment.errors.on(:name)
    end
  end
  
  def test_should_require_valid_name
    assert_no_difference 'RoleAssignment.count' do
      role_assignment = create_role_assignment(:name => 'this_is_not_a_role')
      assert role_assignment.errors.on(:name)
    end
  end
  
    def test_should_require_user
    assert_no_difference 'RoleAssignment.count' do
      role_assignment = create_role_assignment(:user => nil)
      assert role_assignment.errors.on(:user)
    end
  end
  
  protected
    def create_role_assignment(options = {})
      RoleAssignment.create({ :user => users(:editor), :node => nodes(:about_page_node), :name => "final_editor" }.merge(options))
    end
end
