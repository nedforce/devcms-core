require File.dirname(__FILE__) + '/../test_helper'

class NodeParanoidDeleteTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true
  
  def setup
    @editor = users(:editor)
    @root_section = sections(:root_section)
    @root_section_node = nodes(:root_section_node)
    @economie_section = sections(:economie_section)
    @economie_section_node = nodes(:economie_section_node)
    @economie_poll_node = nodes(:economie_poll_node)
    @category = categories(:category_blaat)
  end
  
  def test_should_not_paranoid_delete_root
    assert_raises ActiveRecord::ActiveRecordError do
      @root_section_node.paranoid_delete!
    end
    
    assert_nil @root_section_node.deleted_at
    assert Node.exists?(@root_section_node)
  end
  
  def test_should_paranoid_delete_non_root
    assert @economie_section_node.paranoid_delete!
    assert_not_nil @economie_section_node.reload.deleted_at
    assert !Node.exists?(@economie_section_node)
  end
  
  def test_should_set_deleted_at_on_paranoid_delete
    now = Time.now
    Time.stubs(:now => now)
    @economie_section_node.paranoid_delete!
    assert_equal now, @economie_section_node.reload.deleted_at
  end
  
  def test_default_scope_should_filter_out_paranoid_deleted_nodes
    assert_equal @economie_section_node, Node.find(@economie_section_node)
    
    @economie_section_node.paranoid_delete!
    
    assert !Node.exists?(@economie_section_node)
  end
  
  def test_paranoid_delete_should_also_delete_descendants
    node = create_node(@economie_section_node)
    
    assert Node.exists?(node)
    
    @economie_section_node.paranoid_delete!
    
    assert !Node.exists?(@economie_section_node)
    assert !Node.exists?(node)
  end
  
  def test_acts_as_content_node_default_scope_should_filter_out_paranoid_deleted_nodes
    assert_equal @economie_section, Section.find(@economie_section)
    
    @economie_section_node.paranoid_delete!
    
    assert !Section.exists?(@economie_section)
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
    
    nc1 = create_node_category(@economie_section_node)
    nc2 = create_node_category(node)
    
    assert_equal @economie_section_node, Node.global_frontpage
        
    assert Node.exists?(@economie_section_node)
    assert Node.exists?(node)
    
    assert ContentCopy.exists?(cc1)
    assert ContentCopy.exists?(cc2)
    assert ContentCopy.exists?(cc3)
    assert ContentCopy.exists?(cc4)
    
    assert InternalLink.exists?(il1)
    assert InternalLink.exists?(il2)
    assert InternalLink.exists?(il3)
    assert InternalLink.exists?(il4)
    
    assert ContentRepresentation.exists?(cr1)
    assert ContentRepresentation.exists?(cr2)
    
    assert RoleAssignment.exists?(ra1)
    assert RoleAssignment.exists?(ra2)
    
    assert Synonym.exists?(s1)
    assert Synonym.exists?(s2)
    
    assert Abbreviation.exists?(a1)
    assert Abbreviation.exists?(a2)
    
    assert NodeCategory.exists?(nc1)
    assert NodeCategory.exists?(nc2)
                
    @economie_section_node.paranoid_delete!

    assert_equal @root_section_node, Node.global_frontpage
    
    assert !Node.exists?(@economie_section_node)
    assert !Node.exists?(node)
    
    assert !ContentCopy.exists?(cc1)
    assert !ContentCopy.exists?(cc2)
    assert !ContentCopy.exists?(cc3)
    assert !ContentCopy.exists?(cc4)
    
    assert !InternalLink.exists?(il1)
    assert !InternalLink.exists?(il2)
    assert !InternalLink.exists?(il3)
    assert !InternalLink.exists?(il4)
    
    assert !ContentRepresentation.exists?(cr1)
    assert !ContentRepresentation.exists?(cr2)
    
    assert !RoleAssignment.exists?(ra1)
    assert !RoleAssignment.exists?(ra2)
    
    assert !Synonym.exists?(s1)
    assert !Synonym.exists?(s2)
    
    assert !Abbreviation.exists?(a1)
    assert !Abbreviation.exists?(a2)
    
    assert !NodeCategory.exists?(nc1)
    assert !NodeCategory.exists?(nc2)
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

protected

  def create_node(parent = nodes(:root_section_node))
    p = Page.create! :parent => parent, :title => "Page title", :body => "Page body", :expires_on => 1.day.from_now.to_date
    p.node
  end
  
  def create_content_copy(parent_node, node_to_copy)
    ContentCopy.create!({:parent => parent_node, :copied_node => node_to_copy })
  end

  def create_internal_link(parent_node, node_to_link)
    InternalLink.create!({:parent => parent_node, :title => "Dit is een internal link.", :description => "Geen fratsen!", :linked_node => node_to_link })
  end
  
  def create_content_representation(parent_node, content_node)
    ContentRepresentation.create({ :parent => parent_node, :content => content_node, :target => 'primary_column' })
  end
  
  def create_role_assignment(target_node)
    RoleAssignment.create({ :user => users(:editor), :node => target_node, :name => "final_editor" })
  end
  
  def create_synonym(target_node, name)
    Synonym.create({ :original => "foo", :name => name, :weight => "0.25", :node => target_node })
  end
  
  def create_abbreviation(target_node)
    Abbreviation.create({ :abbr => "snafu", :definition => "Situation Normal All Fucked Up", :node => target_node})
  end
  
  def create_node_category(target_node)
    NodeCategory.create({ :node => target_node, :category => @category })
  end

end