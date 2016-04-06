require File.expand_path('../../test_helper.rb', __FILE__)

class NodeParanoidDeleteTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  setup do
    @editor                = users(:editor)
    @root_section          = sections(:root_section)
    @root_section_node     = nodes(:root_section_node)
    @economie_section      = sections(:economie_section)
    @economie_section_node = nodes(:economie_section_node)
    @economie_poll_node    = nodes(:economie_poll_node)
  end

  def test_should_not_paranoid_delete_root
    assert_raises ActiveRecord::ActiveRecordError do
      @root_section_node.paranoid_delete!
    end

    assert_nil @root_section_node.deleted_at
    assert Node.exists?(@root_section_node.id)
  end

  def test_should_paranoid_delete_non_root
    assert @economie_section_node.paranoid_delete!
    assert_not_nil @economie_section_node.reload.deleted_at
    refute Node.exists?(@economie_section_node.id)
  end

  def test_should_set_deleted_at_on_paranoid_delete
    now = Time.zone.now
    Time.stubs(:now => now)
    assert @economie_section_node.paranoid_delete!
    assert_equal now, @economie_section_node.reload.deleted_at
  end

  def test_default_scope_should_filter_out_paranoid_deleted_nodes
    assert_equal @economie_section_node, Node.find(@economie_section_node.id)

    @economie_section_node.paranoid_delete!

    refute Node.exists?(@economie_section_node.id)
  end

  def test_paranoid_delete_should_also_delete_descendants
    node = create_node(@economie_section_node)

    assert Node.exists?(node.id)

    @economie_section_node.paranoid_delete!

    refute Node.exists?(@economie_section_node.id)
    refute Node.exists?(node.id)
  end

  def test_paranoid_delete_should_skip_previously_deleted_descendants
    node = create_node(@economie_section_node)

    assert Node.exists?(node.id)

    node.paranoid_delete!

    refute Node.exists?(node.id)

    @economie_section_node.paranoid_delete!

    refute Node.exists?(@economie_section_node.id)
  end

  def test_acts_as_content_node_default_scope_should_filter_out_paranoid_deleted_nodes
    assert_equal @economie_section, Section.find(@economie_section.id)
    assert @economie_section_node.paranoid_delete!
    refute Section.exists?(@economie_section.id)
  end

  def test_paranoid_delete_should_also_delete_associated_content_for_nodes
    @root_section.set_frontpage!(@economie_section_node)

    node = create_node(@economie_section_node)

    cc1 = create_content_copy(@root_section_node, @economie_section_node)
    cc2 = create_content_copy(@root_section_node, node)
    cc3 = create_content_copy(@economie_section_node, @economie_section_node)
    cc4 = create_content_copy(@economie_section_node, node)

    il1 = create_internal_link(@root_section_node, @economie_section_node)
    il2 = create_internal_link(@root_section_node, node)
    il3 = create_internal_link(@economie_section_node, @economie_section_node)
    il4 = create_internal_link(@economie_section_node, node)

    cr1 = create_content_representation(@root_section_node, @economie_section_node)
    cr2 = create_content_representation(@economie_section_node, @economie_poll_node)

    ra1 = create_role_assignment(@economie_section_node)
    ra2 = create_role_assignment(node)

    s1 = create_synonym(@economie_section_node, 'blaat')
    s2 = create_synonym(node, 'mekker')

    a1 = create_abbreviation(@economie_section_node)
    a2 = create_abbreviation(node)

    c1 = create_comment(@economie_section_node)
    c2 = create_comment(node)

    assert_equal @economie_section_node, Node.global_frontpage

    assert Node.exists?(@economie_section_node.id)
    assert Node.exists?(node.id)

    assert ContentCopy.exists?(cc1.id)
    assert ContentCopy.exists?(cc2.id)
    assert ContentCopy.exists?(cc3.id)
    assert ContentCopy.exists?(cc4.id)

    assert InternalLink.exists?(il1.id)
    assert InternalLink.exists?(il2.id)
    assert InternalLink.exists?(il3.id)
    assert InternalLink.exists?(il4.id)

    assert ContentRepresentation.exists?(cr1.id)
    assert ContentRepresentation.exists?(cr2.id)

    assert RoleAssignment.exists?(ra1.id)
    assert RoleAssignment.exists?(ra2.id)

    assert Synonym.exists?(s1.id)
    assert Synonym.exists?(s2.id)

    assert Abbreviation.exists?(a1.id)
    assert Abbreviation.exists?(a2.id)

    assert Comment.exists?(c1.id)
    assert Comment.exists?(c2.id)

    @economie_section_node.paranoid_delete!

    assert_equal @root_section_node, Node.global_frontpage

    refute Node.exists?(@economie_section_node.id)
    refute Node.exists?(node.id)
    refute Section.where(:id => @economie_section_node.content.id).first.present?
    refute Page.where(:id => node.content.id).first.present?

    refute ContentCopy.exists?(cc1.id)
    refute ContentCopy.exists?(cc2.id)
    refute ContentCopy.exists?(cc3.id)
    refute ContentCopy.exists?(cc4.id)

    refute InternalLink.exists?(il1.id)
    refute InternalLink.exists?(il2.id)
    refute InternalLink.exists?(il3.id)
    refute InternalLink.exists?(il4.id)

    refute ContentRepresentation.exists?(cr1.id)
    refute ContentRepresentation.exists?(cr2.id)

    refute RoleAssignment.exists?(ra1.id)
    refute RoleAssignment.exists?(ra2.id)

    refute Synonym.exists?(s1.id)
    refute Synonym.exists?(s2.id)

    refute Abbreviation.exists?(a1.id)
    refute Abbreviation.exists?(a2.id)

    refute Comment.exists?(c1.id)
    refute Comment.exists?(c2.id)
  end

  def test_paranoid_delete_should_also_delete_associated_versions
    page = Page.new(:title => 'Page title', :preamble => 'Ambule', :body => 'Version for delete', :parent => @economie_section_node, :expires_on => 1.day.from_now.to_date)

    assert_difference('Page.count', 1) do
      assert_difference('Version.count', 1) do
        assert page.save(:user => @editor)
      end
    end

    assert_difference('Version.count', -1) do
      page.node.paranoid_delete!
    end
  end

  def test_top_level_deleted_should_not_include_paranoid_deleted_descendants
    node = create_node(@economie_section_node)

    assert Node.exists?(node.id)

    @economie_section_node.paranoid_delete!

    refute Node.exists?(@economie_section_node.id)
    refute Node.exists?(node.id)

    assert Node.deleted.include?(@economie_section_node)
    assert Node.deleted.include?(node)

    assert Node.top_level_deleted.include?(@economie_section_node)
    refute Node.top_level_deleted.include?(node)
  end

  def test_paranoid_restore_should_restore_paranoid_deleted_node
    @economie_section_node.paranoid_delete!

    refute Node.exists?(@economie_section_node.id)

    assert Node.deleted.include?(@economie_section_node)

    @economie_section_node.paranoid_restore!

    assert Node.exists?(@economie_section_node.id)

    refute Node.deleted.include?(@economie_section_node)

    assert_nil @economie_section_node.reload.deleted_at
  end

  def test_paranoid_restore_should_not_restore_paranoid_deleted_node_if_parent_is_also_paranoid_deleted
    node = create_node(@economie_section_node)

    assert Node.exists?(node.id)

    @economie_section_node.paranoid_delete!

    refute Node.exists?(@economie_section_node.id)
    refute Node.exists?(node.id)

    assert_raises RuntimeError do
      node.paranoid_restore!
    end
  end

  def test_paranoid_restore_should_restore_paranoid_deleted_descendants
    node = create_node(@economie_section_node)

    assert Node.exists?(node.id)

    @economie_section_node.paranoid_delete!

    refute Node.exists?(@economie_section_node.id)
    refute Node.exists?(node.id)

    @economie_section_node.paranoid_restore!

    assert Node.exists?(@economie_section_node.id)
    assert Node.exists?(node.id)

    refute Node.deleted.include?(@economie_section_node)
    refute Node.deleted.include?(node)

    assert_nil @economie_section_node.reload.deleted_at
    assert_nil node.reload.deleted_at
  end

  def test_paranoid_restore_should_restore_associated_content
    node = create_node(@economie_section_node)

    cc = create_content_copy(@economie_section_node, @economie_section_node)

    assert Node.exists?(node.id)
    assert ContentCopy.exists?(cc.id)

    @economie_section_node.paranoid_delete!

    refute Node.exists?(@economie_section_node.id)
    refute Node.exists?(node.id)
    refute ContentCopy.exists?(cc.id)

    @economie_section_node.paranoid_restore!

    assert Node.exists?(@economie_section_node.id)
    assert Node.exists?(node.id)
    assert ContentCopy.exists?(cc.id)

    refute Node.deleted.include?(@economie_section_node)
    refute Node.deleted.include?(node)

    assert @economie_section_node.content.present?
    assert node.content.present?

    assert_nil @economie_section_node.content.reload.deleted_at
    assert_nil node.content.reload.deleted_at
    assert_nil cc.reload.deleted_at
  end

  def test_delete_all_paranoid_deleted_content_should_not_delete_non_paranoid_deleted_content
    node = create_node(@economie_section_node)

    Node.delete_all_paranoid_deleted_content!

    assert Node.exists?(node.id)
    assert node.content.present?
  end

  def test_delete_all_paranoid_deleted_content_should_delete_paranoid_deleted_content
    node = create_node(@economie_section_node)
    content = node.content

    Node.delete_all_paranoid_deleted_content!

    assert Node.exists?(node.id)
    assert node.content.present?

    @economie_section_node.paranoid_delete!

    refute Node.exists?(@economie_section_node.id)
    refute Node.exists?(node.id)
    refute Section.exists?(@economie_section.id)
    refute Page.exists?(content.id)

    Node.unscoped do
      assert Node.exists?(@economie_section_node.id)
      assert Node.exists?(node.id)
    end

    Section.unscoped do
      assert Section.exists?(@economie_section.id)
    end

    Page.unscoped do
      assert Page.exists?(content.id)
    end

    Node.delete_all_paranoid_deleted_content!

    Node.unscoped do
      refute Node.exists?(@economie_section_node.id)
      refute Node.exists?(node.id)
    end

    Section.unscoped do
      refute Section.exists?(@economie_section.id)
    end

    Page.unscoped do
      refute Page.exists?(content.id)
    end
  end

protected

  def create_node(parent = nodes(:root_section_node))
    p = Page.create! :parent => parent, :title => 'Page title', :body => 'Page body', :expires_on => 1.day.from_now.to_date
    p.node
  end

  def create_content_copy(parent_node, node_to_copy)
    ContentCopy.create!({ :parent => parent_node, :copied_node => node_to_copy })
  end

  def create_internal_link(parent_node, node_to_link)
    InternalLink.create!({ :parent => parent_node, :title => 'Dit is een internal link.', :description => 'Geen fratsen!', :linked_node => node_to_link })
  end

  def create_content_representation(parent_node, content_node)
    ContentRepresentation.create({ :parent => parent_node, :content => content_node, :target => 'primary_column' })
  end

  def create_role_assignment(target_node)
    RoleAssignment.create({ :user => users(:editor), :node => target_node, :name => 'final_editor' })
  end

  def create_synonym(target_node, name)
    Synonym.create({ :original => 'foo', :name => name, :weight => '0.25', :node => target_node })
  end

  def create_abbreviation(target_node)
    Abbreviation.create({ :abbr => 'snafu', :definition => 'Situation Normal All Fucked Up', :node => target_node })
  end

  def create_comment(target_node)
    Comment.create({ :user => users(:arthur), :commentable => target_node, :comment => "I don't like it!" })
  end
end
