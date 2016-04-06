require File.expand_path('../../test_helper.rb', __FILE__)

class EditorApprovalRequirementTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  setup do
    # Make sure no versions are in the database yet
    Version.delete_all

    @editor_section_page_node = nodes(:editor_section_page_node)
    @editor_section_node      = nodes(:editor_section_node)
    @arthur                   = users(:arthur)
    @editor                   = users(:editor)
    @final_editor             = users(:final_editor)
    @final_editor.role_assignments.first.update_attribute :node, @editor_section_node
  end

  def test_save_for_user_for_editor_on_new_node_created_by_editor
    page = Page.new(:title => 'Page title', :preamble => 'Ambule', :body => 'Version 1', :parent => @editor_section_node)

    assert_difference('Page.count', 1) do
      assert page.save(:user => @editor)
      assert_equal @editor_section_node, page.node.parent

      refute page.node.publishable?
      assert page.previous_version.nil?
      assert_equal 'Version 1', page.body
      assert_equal 'Version 1', page.current_version.body

      page.body = 'Version 2'
      assert page.save(:user => @editor)

      refute page.node.publishable?
      assert page.previous_version.nil?
      assert_equal 'Version 2', page.body
      assert_equal 'Version 2', page.current_version.body
    end
  end

  def test_save_for_user_for_editor_on_existing_node_created_by_admin
    page = create_page :body => 'Version 1'

    assert page.node.publishable?
    assert_equal 'Version 1', page.body
    assert_equal 'Version 1', page.current_version.body
    assert page.previous_version.nil?

    page.body = 'Version 2'
    assert page.save(:user => @editor)

    page = page.reload

    assert_equal 'Version 1', page.body
    assert_equal 'Version 2', page.current_version.body
    assert_equal 'Version 1', page.previous_version.body

    page.body = 'Version 3'
    assert page.save(:user => @editor)

    page = page.reload

    assert_equal 'Version 1', page.body
    assert_equal 'Version 3', page.current_version.body
    assert_equal 'Version 1', page.previous_version.body
  end

  def test_save_for_user_for_admin_on_new_node_created_by_editor_without_approval_required
    page = Page.new(:title => 'Page title', :preamble => 'Ambule', :body => 'Version 1', :parent => @editor_section_node)

    assert_difference('Page.count', 1) do
      assert page.save(:user => @editor)

      refute page.node.publishable?
      assert_equal 'Version 1', page.current_version.body
      assert page.previous_version.nil?

      page.body = 'Version 2'
      assert page.save(:user => @arthur)

      page = page.reload

      assert page.node.publishable?
      assert_equal 'Version 2', page.body
      assert_equal 'Version 2', page.current_version.body
      assert page.previous_version.nil?
    end
  end

  def test_save_for_user_for_admin_on_new_node_created_by_editor_with_approval_required
    page = Page.new(:title => 'Page title', :preamble => 'Ambule', :body => 'Version 1', :parent => @editor_section_node)

    assert_difference('Page.count', 1) do
      assert page.save(:user => @editor)

      refute page.node.publishable?
      assert_equal 'Version 1', page.current_version.body
      assert page.previous_version.nil?

      page.body = 'Version 2'
      assert page.save(:user => @arthur, :approval_required => true)

      refute page.node.publishable?
      assert_equal 'Version 2', page.current_version.body
      assert page.previous_version.nil?
    end
  end

  def test_save_for_user_for_admin_on_already_versioned_node_without_approval_required
    page = create_page :body => 'Version 1'

    assert page.node.publishable?
    assert_equal 'Version 1', page.body
    assert_equal 'Version 1', page.current_version.body
    assert page.previous_version.nil?

    page.body = 'Version 2'
    assert page.save(:user => @editor)

    page = page.reload

    assert_equal 'Version 1', page.body
    assert_equal 'Version 2', page.current_version.body
    assert_equal 'Version 1', page.previous_version.body

    page.body = 'Version 3'
    assert page.save(:user => @arthur)

    page = page.reload

    assert_equal 'Version 3', page.body
    assert_equal 'Version 3', page.current_version.body
    assert page.previous_version.nil?
  end

  def test_save_for_user_for_final_editor_on_already_versioned_node_without_approval_required
    page = create_page :body => 'Version 1'

    assert page.node.publishable?
    assert_equal 'Version 1', page.body
    assert_equal 'Version 1', page.current_version.body
    assert page.previous_version.nil?

    page.body = 'Version 2'
    assert page.save(:user => @editor)

    page = page.reload

    assert_equal 'Version 1', page.body
    assert_equal 'Version 2', page.current_version.body
    assert_equal 'Version 1', page.previous_version.body

    page.body = 'Version 3'
    assert page.save(:user => @final_editor)

    page = page.reload

    assert_equal 'Version 3', page.body
    assert_equal 'Version 3', page.current_version.body
    assert page.previous_version.nil?
  end

  def test_save_for_user_for_admin_on_already_versioned_node_with_approval_required
    page = create_page :body => 'Version 1'

    assert page.node.publishable?
    assert_equal 'Version 1', page.body
    assert_equal 'Version 1', page.current_version.body
    assert page.previous_version.nil?

    page.body = 'Version 2'
    assert page.save(:user => @editor)

    page = page.reload

    assert_equal 'Version 1', page.body
    assert_equal 'Version 2', page.current_version.body
    assert_equal 'Version 1', page.previous_version.body

    page.body = 'Version 3'
    assert page.save(:user => @arthur, :approval_required => true)

    page = page.reload

    assert_equal 'Version 1', page.body
    assert_equal 'Version 3', page.current_version.body
    assert_equal 'Version 1', page.previous_version.body
  end

  def test_save_for_user_for_admin_on_new_node_created_by_admin
    page = Page.new(:title => 'Page title', :preamble => 'Ambule', :body => 'Version 1', :parent => @editor_section_node)

    assert_difference('Page.count', 1) do
      assert page.save(:user => @arthur)

      assert page.node.publishable?
      assert_equal 'Version 1', page.current_version.body
      assert page.previous_version.nil?

      page.body = 'Version 2'
      assert page.save(:user => @arthur)

      assert_equal 'Version 2', page.current_version.body
      assert page.previous_version.nil?
    end
  end

  def test_save_for_user_for_admin_on_existing_node_created_by_admin
    page = create_page :body => 'Version 1'
    page.body = 'Version 2'
    page.save(:user => @arthur)

    assert page.node.publishable?
    assert_equal 'Version 2', page.current_version.body
    assert page.previous_version.nil?

    page.body = 'Version 3'
    assert page.save(:user => @arthur)

    assert_equal 'Version 3', page.current_version.body
    assert page.previous_version.nil?
  end

  def test_update_attributes_for_user_without_approval_required
    page = create_page :body => 'Version 1'

    assert page.node.publishable?
    assert_equal 'Version 1', page.body
    assert_equal 'Version 1', page.current_version.body
    assert page.previous_version.nil?

    assert page.update_attributes(:user => @editor, :body => 'Version 2')

    page.node.reload
    page = page.reload

    assert_equal 'Version 1', page.body
    assert_equal 'Version 2', page.current_version.body
    assert_equal 'Version 1', page.previous_version.body

    assert page.update_attributes(:user => @arthur, :body => 'Version 3')

    assert_equal 'Version 3', page.body
    assert_equal 'Version 3', page.current_version.body
    assert page.previous_version.nil?
  end

  def test_update_attributes_for_user_with_approval_required
    page = create_page :body => 'Version 1'

    assert page.node.publishable?
    assert_equal 'Version 1', page.body
    assert_equal 'Version 1', page.current_version.body
    assert page.previous_version.nil?

    assert page.update_attributes(:user => @editor, :body => 'Version 2')

    page = page.reload

    assert_equal 'Version 1', page.body
    assert_equal 'Version 2', page.current_version.body
    assert_equal 'Version 1', page.previous_version.body

    assert page.update_attributes(:user => @arthur, :body => 'Version 3', :approval_required => true)

    page = page.reload

    assert_equal 'Version 1', page.body
    assert_equal 'Version 3', page.current_version.body
    assert_equal 'Version 1', page.previous_version.body
  end

  def test_should_show_previous_version_when_drafted
    page = Page.create({ :user => @arthur, :parent => nodes(:editor_section_node), :title => 'Page title', :preamble => 'Ambule', :body => 'Version 1' , :expires_on => 1.day.from_now.to_date })

    assert page.node.publishable?
    assert_equal 'Version 1', page.body
    assert_equal 'Version 1', page.current_version.body
    assert page.previous_version.nil?

    page.update_attributes(:user => users(:editor), :body => 'Version 2', :draft => true) # Update page as editor. No version is saved.

    page = page.reload

    assert_equal 'Version 1', page.body
    assert_equal 'Version 2', page.current_version.body
    assert page.current_version.draft?
    assert_equal 'Version 1', page.previous_version.body
  end

  def test_should_copy_editor_and_editor_comment_on_admin_edit
    page = create_page

    page.title = 'Version 1'
    page.editor_comment = 'Version 1 comment'
    assert page.save(user: @editor)

    current_version = page.versions.last
    assert_equal 'Version 1', current_version.model.title
    assert_equal @editor, current_version.editor
    assert_equal 'Version 1 comment', current_version.editor_comment

    page.title = 'Version 2'
    page.editor_comment = 'Version 2 comment' # This editor comment will be ignored

    assert page.save(user: @arthur, approval_required: true)
    current_version = page.versions.last
    assert_equal 'Version 2', current_version.model.title
    assert_equal @editor, current_version.editor
    assert_equal 'Version 1 comment', current_version.editor_comment
  end

  protected

  def create_page(options = {})
    Page.create({ :user => @arthur, :parent => nodes(:editor_section_node), :title => 'Page title', :preamble => 'Ambule', :body => 'Page body' }.merge(options))
  end
end
