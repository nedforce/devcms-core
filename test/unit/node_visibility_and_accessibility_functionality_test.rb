require File.expand_path('../../test_helper.rb', __FILE__)

class NodeVisibilityAndAccessibilityFunctionalityTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  def setup
    @admin = users(:arthur)
    @editor = users(:editor)
    @root_section = sections(:root_section)
    @root_section_node = nodes(:root_section_node)
    @economie_section_node = nodes(:economie_section_node)
    @editor_section_node= nodes(:editor_section_node)
    @sub_site_section = nodes(:sub_site_section_node)
  end

  def test_has_hidden_ancestor?
    assert !@economie_section_node.has_hidden_ancestor?
    @root_section_node.update_attribute(:hidden, true)
    assert @economie_section_node.has_hidden_ancestor?
  end
  
  def test_has_private_ancestor?
    assert !@economie_section_node.has_private_ancestor?
    @root_section_node.update_attribute(:private, true)
    assert @economie_section_node.has_private_ancestor?
  end
  
  def test_accessible_scope_should_not_find_hidden_nodes
    node = create_node
    assert_not_nil Node.accessible.find_by_id(node.id)
    node.update_attribute(:hidden, true)
    assert_nil Node.accessible.find_by_id(node.id)
  end
  
  def test_accessible_scope_should_find_private_nodes
    node = create_node
    assert_not_nil Node.accessible.find_by_id(node.id)
    node.update_attribute(:private, true)
    assert_not_nil Node.accessible.find_by_id(node.id)
  end
  
  def test_private_scope
    node = create_node
    assert_nil Node.private.find_by_id(node.id)
    node.update_attribute(:private, true)
    assert_not_nil Node.private.find_by_id(node.id)
  end
  
  def test_public_scope
    node = create_node
    assert_not_nil Node.public.find_by_id(node.id)
    node.update_attribute(:private, true)
    assert_nil Node.public.find_by_id(node.id)
  end
  
  def test_accessible_for_user?
    node = create_node({}, @editor_section_node)
    
    assert node.accessible_for_user?(@admin)
    assert node.accessible_for_user?(@editor)
    
    @editor_section_node.update_attribute(:private, true)
    
    assert node.accessible_for_user?(@admin)
    assert node.accessible_for_user?(@editor)
    
    node = create_node({}, @sub_site_section)
    
    assert node.accessible_for_user?(@admin)
    assert node.accessible_for_user?(@editor)
    
    @sub_site_section.update_attribute(:private, true)
    
    assert node.accessible_for_user?(@admin)
    assert !node.accessible_for_user?(@editor)
  end
  
  def test_set_visibility_should_hide_node_and_descendants
    5.times do    
      create_node({}, @editor_section_node)
    end
    
    assert @editor_section_node.set_visibility!(false)
    
    @editor_section_node.self_and_descendants do |node|
      assert node.hidden?
    end
  end
  
  def test_set_visibility_should_make_node_and_descendants_visible
    assert @editor_section_node.set_visibility!(false)
    
    5.times do    
      create_node({}, @editor_section_node)
    end
    
    assert @editor_section_node.set_visibility!(true)
    
    @editor_section_node.self_and_descendants do |node|
      assert !node.hidden?
    end
  end
  
  def test_set_accessibility_should_make_section_node_private
    assert @editor_section_node.set_accessibility!(false)
    assert @editor_section_node.private?
  end
  
  def test_set_accessibility_should_not_make_non_section_node_private
    node = create_node({}, @editor_section_node)
    
    assert !node.set_accessibility!(false)
    assert !node.private?
  end
  
  def test_set_accessibility_should_make_section_node_public
    assert @editor_section_node.set_accessibility!(false)
    assert @editor_section_node.set_accessibility!(true)
    assert !@editor_section_node.private?
  end
  
  def test_should_not_make_global_frontpage_private
     @root_section.set_frontpage!(@economie_section_node)
     assert !@economie_section_node.set_accessibility!(false)
     assert !@root_section_node.set_accessibility!(false)
     @root_section.set_frontpage!(@root_section_node)
     assert @economie_section_node.set_accessibility!(false)
     assert !@root_section_node.set_accessibility!(false)
   end
   
   def test_should_not_hide_global_frontpage
     @root_section.set_frontpage!(@economie_section_node)
     assert !@economie_section_node.set_visibility!(false)
     assert !@root_section_node.set_visibility!(false)
     @root_section.set_frontpage!(@root_section_node)
     assert @economie_section_node.set_visibility!(false)
     assert !@root_section_node.set_visibility!(false)
    end
  
protected

  def create_node(options = {}, parent_node = nodes(:root_section_node))
    create_page({ :parent => parent_node }.merge(options)).node
  end
  
  def create_page(options = {})
    Page.create!({ :user => @admin, :parent => @root_section_node, :title => 'foo', :body => 'bar', :publication_start_date => 1.day.ago }.merge(options))
  end
  
  
 
end