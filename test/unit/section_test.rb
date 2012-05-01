require File.expand_path('../../test_helper.rb', __FILE__)

class SectionTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  def setup
    @root_node              = nodes(:root_section_node)
    @root_section           = sections(:root_section)
    @news_archive_node      = nodes(:devcms_news_node)
    @section_with_frontpage = sections(:section_with_frontpage)
    @about_page_node        = nodes(:about_page_node)
  end

  def test_should_create_section
    assert_difference('Section.count') do
      section = create_section
      assert !section.new_record?
    end
  end

  def test_should_require_title
    assert_no_difference('Section.count') do
      section = create_section(:title => nil)
      assert section.new_record?
      assert section.errors[:title].any?
    end
  end

  def test_last_should_be_blank
    s = Section.all.last
    s.update_attribute(:description, nil)
    s.reload
    assert_nil s.description
  end

  # Frontpage functionality related tests

  def test_should_not_require_frontpage_node
    assert_difference('Section.count') do
      section = create_section(:frontpage_node => nil)
      assert !section.new_record?
      assert_nil section.frontpage_node
    end
  end

  def test_should_not_accept_frontpage_node_during_creation
    assert_no_difference('Section.count') do
      section = create_section(:frontpage_node => @root_node)
      assert !section.valid?
      assert section.errors[:base].any?
    end
  end

  def test_set_frontpage!
    assert_equal @news_archive_node, @root_section.frontpage_node
    @root_section.set_frontpage!(@about_page_node)
    assert_equal @about_page_node, @root_section.frontpage_node
  end

  def test_should_set_frontpage_node_to_nil_if_frontpage_node_is_own_node
    @root_section.set_frontpage!(@root_section_node)
    assert @root_section.valid?
    assert !@root_section.errors[:frontpage_node].any?
    assert !@root_section.has_frontpage?
    assert_equal nil, @root_section.frontpage_node
  end
  # 
  # def test_should_accept_descendant_as_frontpage_node
  #   @root_section.set_frontpage!(@news_archive_node)
  #   assert @root_section.valid?
  #   assert !@root_section.errors[:frontpage_node].any?
  #   assert_equal @news_archive_node, @root_section.frontpage_node
  # end
  # 
  # def test_should_not_accept_ancestor_as_frontpage_node
  #   section = create_section
  #   section.set_frontpage!(@root_node)
  #   assert !section.valid?
  #   assert section.errors[:base].any?
  # end
  # 
  # def test_should_not_accept_sibling_as_frontpage_node
  #   section = create_section
  #   sibling = create_section
  #   section.set_frontpage!(sibling.node)
  #   assert !section.valid?
  #   assert section.errors[:base].any?
  # end

  def test_should_not_accept_section_with_frontpage_node_as_frontpage_node
    @root_section.set_frontpage!(@section_with_frontpage.node)
    assert !@root_section.valid?
    assert @root_section.errors[:base].any?
  end

  def test_destruction_of_frontpage_node_should_set_frontpage_node_id_to_nil
    assert_no_difference('Section.count') do
      frontpage_node = @section_with_frontpage.frontpage_node
      frontpage_node.destroy
      assert_nil @section_with_frontpage.reload.frontpage_node
    end
  end

  def test_last_updated_at_should_return_updated_at_when_no_accessible_children_are_found
    s = create_section :publication_start_date => 1.day.ago
    assert_equal s.updated_at.to_i, s.last_updated_at.to_i

    p = create_page s, :publication_start_date => 1.day.ago
    
    p.node.hidden = true
    p.node.save!
    
    assert_equal s.updated_at.to_i, s.last_updated_at.to_i
  end
  
protected
  
  def create_section(options={})
    Section.create({ :parent => nodes(:root_section_node), :title => 'new section', :description => 'new description for section.' }.merge(options))
  end

  def create_page(parent, options = {})
    Page.create({ :parent => parent.node, :title => "Page title", :preamble => "Ambule", :body => "Page body", :expires_on => 1.day.from_now.to_date }.merge(options)).reload
  end
end
