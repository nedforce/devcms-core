require File.dirname(__FILE__) + '/../test_helper'

class NodeParanoidDeleteTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true
  
  def setup
    @root_section_node = nodes(:root_section_node)
    @economie_section = sections(:economie_section)
    @economie_section_node = nodes(:economie_section_node)
    @editor = users(:editor)
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
    node1 = create_node(@economie_section_node)
    node2 = create_node(@economie_section_node)
    
    cc1 = create_content_copy(node1)
    cc2 = create_content_copy(node2)
    
    il1 = create_internal_link(node1)
    il2 = create_internal_link(node2)
    
    assert Node.exists?(node1)
    assert Node.exists?(node2)
    
    assert ContentCopy.exists?(cc1)
    assert ContentCopy.exists?(cc2)
    
    assert InternalLink.exists?(il1)
    assert InternalLink.exists?(il2)
            
    @economie_section_node.paranoid_delete!
    
    assert !Node.exists?(node1)
    assert !Node.exists?(node2)
    
    assert !ContentCopy.exists?(cc1)
    assert !ContentCopy.exists?(cc2)
    
    assert !InternalLink.exists?(il1)
    assert !InternalLink.exists?(il2)
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
  
  def create_content_copy(node_to_copy)
    ContentCopy.create!({:parent => @economie_section_node, :copied_node => node_to_copy })
  end

  def create_internal_link(node_to_link)
    InternalLink.create!({:parent => @economie_section_node, :title => "Dit is een internal link.", :description => "Geen fratsen!", :linked_node => node_to_link })
  end

end