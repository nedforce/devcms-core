require File.dirname(__FILE__) + '/../test_helper'

class EditorApprovalRequirementTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true
    
  def setup
    # Make sure no versions are in the database yet
    Version.delete_all

    @editor_section_page_node = nodes(:editor_section_page_node)
    @editor_section_node = nodes(:editor_section_node)
    @arthur = users(:arthur)
    @editor = users(:editor)
  end
  
  def test_save_for_user_for_editor_on_new_node_created_by_editor
    page = Page.new(:title => "Page title", :preamble => "Ambule", :body => "Version 1", :parent => @editor_section_node)
    
    assert_difference('Page.count', 1) do
      assert page.save_for_user(@editor)
      assert_equal @editor_section_node, page.node.parent

      assert !page.approved?
      assert page.versions.empty?
      assert_equal 0, page.version_number
      assert_equal "Version 1", page.body

      page.body = 'Version 2'
      assert page.save_for_user(@editor)

      assert !page.approved?
      assert_equal 0, page.versions.size
      assert_equal 0, page.version_number
      assert_equal 'Version 2', page.body
    end
  end

  def test_save_for_user_for_editor_on_existing_node_created_by_admin
    page = create_page :body => 'Version 1'
    assert page.approved?

    page.body = 'Version 2'
    assert page.save_for_user(@editor)

    assert !page.approved?
    assert_equal 1, page.versions.size
    assert_equal 1, page.version_number
    assert_equal 'Version 2', page.body
    assert_equal 'Version 1', page.previous_version.body

    page.body = 'Version 3'
    assert page.save_for_user(@editor)

    assert !page.approved?
    assert_equal 1, page.versions.size
    assert_equal 1, page.version_number
    assert_equal 'Version 3', page.body
    assert_equal 'Version 1', page.previous_version.body
  end

  def test_save_for_user_for_admin_on_new_node_created_by_editor_without_skip_approval
    page = Page.new(:title => "Page title", :preamble => "Ambule", :body => "Version 1", :parent => @editor_section_node)

    assert_difference('Page.count', 1) do
      assert page.save_for_user(@editor)
      assert_equal @editor_section_node, page.node.parent

      assert !page.approved?
      assert page.versions.empty?
      assert_equal 0, page.version_number
      assert_equal "Version 1", page.body

      page.body = 'Version 2'
      assert page.save_for_user(@arthur)

      assert page.approved?
      assert_equal 0, page.versions.size
      assert_equal 0, page.version_number
      assert_equal 'Version 2', page.body
      assert_equal @arthur.id, page.node.edited_by
    end
  end

  def test_save_for_user_for_admin_on_new_node_created_by_editor_with_skip_approval
    page = Page.new(:title => "Page title", :preamble => "Ambule", :body => "Version 1", :parent => @editor_section_node)

    assert_difference('Page.count', 1) do
      assert page.save_for_user(@editor)
      assert_equal @editor_section_node, page.node.parent

      assert !page.approved?
      assert page.versions.empty?
      assert_equal 0, page.version_number
      assert_equal "Version 1", page.body

      page.body = 'Version 2'
      assert page.save_for_user(@arthur, true)

      assert !page.approved?
      assert_equal 0, page.versions.size
      assert_equal 0, page.version_number
      assert_equal 'Version 2', page.body
      assert_equal @editor.id, page.node.edited_by
    end
  end

  def test_save_for_user_for_admin_on_already_versioned_node_without_skip_approval
    page = create_page :body => 'Version 1'
    assert page.approved?

    page.body = 'Version 2'
    assert page.save_for_user(@editor)

    assert !page.approved?
    assert_equal 1, page.versions.size
    assert_equal 1, page.version_number
    assert_equal 'Version 2', page.body
    assert_equal 'Version 1', page.previous_version.body

    page.body = 'Version 3'
    assert page.save_for_user(@arthur)

    assert page.approved?
    assert_equal 1, page.versions.size
    assert_equal 1, page.version_number
    assert_equal 'Version 3', page.body
    assert_equal 'Version 1', page.previous_version.body
  end

  def test_save_for_user_for_admin_on_already_versioned_node_with_skip_approval
    page = create_page :body => 'Version 1'
    assert page.approved?

    page.body = 'Version 2'
    assert page.save_for_user(@editor)

    assert !page.approved?
    assert_equal 1, page.versions.size
    assert_equal 1, page.version_number
    assert_equal 'Version 2', page.body
    assert_equal 'Version 1', page.previous_version.body

    page.body = 'Version 3'
    assert page.save_for_user(@arthur, true)

    assert !page.approved?
    assert_equal 1, page.versions.size
    assert_equal 1, page.version_number
    assert_equal 'Version 3', page.body
    assert_equal 'Version 1', page.previous_version.body
  end

  def test_save_for_user_for_admin_on_new_node_created_by_admin
    page = Page.new(:title => "Page title", :preamble => "Ambule", :body => "Version 1", :parent => @editor_section_node)

    assert_difference('Page.count', 1) do
      assert page.save_for_user(@arthur)
      assert_equal @editor_section_node, page.node.parent

      assert page.approved?
      assert page.versions.empty?
      assert_equal 0, page.version_number
      assert_equal "Version 1", page.body

      page.body = 'Version 2'
      assert page.save_for_user(@arthur)

      assert page.approved?
      assert_equal 0, page.versions.size
      assert_equal 0, page.version_number
      assert_equal 'Version 2', page.body
    end
  end

  def test_save_for_user_for_admin_on_existing_node_created_by_admin
    page = create_page :body => 'Version 1'
    assert page.approved?

    page.body = 'Version 2'
    page.save_for_user(@arthur)

    assert page.approved?
    assert_equal 0, page.versions.size
    assert_equal 0, page.version_number
    assert_equal 'Version 2', page.body

    page.body = 'Version 3'
    assert page.save_for_user(@arthur)

    assert page.approved?
    assert_equal 0, page.versions.size
    assert_equal 0, page.version_number
    assert_equal 'Version 3', page.body
  end

  def test_update_attributes_for_user_without_skip_approval
    page = create_page :body => 'Version 1'
    assert page.approved?

    page.body = 'Version 2'
    assert page.update_attributes_for_user(@editor, :body => 'Version 2')

    assert !page.approved?
    assert_equal 1, page.versions.size
    assert_equal 1, page.version_number
    assert_equal 'Version 2', page.body
    assert_equal 'Version 1', page.previous_version.body

    assert page.update_attributes_for_user(@arthur, :body => 'Version 3')

    assert page.approved?
    assert_equal 1, page.versions.size
    assert_equal 1, page.version_number
    assert_equal 'Version 3', page.body
    assert_equal 'Version 1', page.previous_version.body
    assert_equal @arthur.id, page.node.edited_by
  end

  def test_update_attributes_for_user_with_skip_approval
    page = create_page :body => 'Version 1'
    assert page.approved?

    page.body = 'Version 2'
    assert page.update_attributes_for_user(@editor, :body => 'Version 2')

    assert !page.approved?
    assert_equal 1, page.versions.size
    assert_equal 1, page.version_number
    assert_equal 'Version 2', page.body
    assert_equal 'Version 1', page.previous_version.body

    assert page.update_attributes_for_user(@arthur, { :body => 'Version 3' }, true)

    assert !page.approved?
    assert_equal 1, page.versions.size
    assert_equal 1, page.version_number
    assert_equal 'Version 3', page.body
    assert_equal 'Version 1', page.previous_version.body
    assert_equal @editor.id, page.node.edited_by
  end

  def test_should_show_previous_version_when_drafted
    page = Page.create_for_user(@arthur, {:parent => nodes(:editor_section_node), :title => "Page title", :preamble => "Ambule", :body => "Page body" })

    page.update_attributes_for_user(users(:editor), :title => 'bar', :draft => "1") # Update page as editor. No version is saved.
    assert page.node.drafted?

    # node.approved_content falls back to saved version.
    assert_equal 'Page title', page.node.approved_content.title
  end

  def test_editor_comment_accessors
    page = pages(:about_page)
    page.editor_comment = 'test'
    assert_equal 'test', page.editor_comment
    assert_equal nil, page.node.editor_comment
  end

  def test_should_store_editor_comment_on_node_on_creation
    page = create_page(:editor_comment => 'test')
    assert_equal 'test', page.editor_comment
    assert_equal 'test', page.node.editor_comment
  end

  def test_should_store_editor_comment_on_node_on_update
    page = create_page
    page.update_attributes_for_user(users(:editor), :title => 'bar', :editor_comment => 'test')
    assert_equal 'test', page.editor_comment
    assert_equal 'test', page.node.editor_comment
  end

protected

  def create_page(options = {})
    Page.create_for_user(@arthur, { :parent => nodes(:editor_section_node), :title => "Page title", :preamble => "Ambule", :body => "Page body" }.merge(options))
  end
  
end
