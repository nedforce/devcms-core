require File.dirname(__FILE__) + '/../test_helper'

class FindAccessibleTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  def setup
    @about_page = pages(:about_page)
    @arthur = users(:arthur)
    @reader = users(:reader)
    @root_node = nodes(:root_section_node)
  end

  def test_should_find_accessible_on_content
    id = @about_page.id
    assert Page.find_accessible(id)
    @about_page.node.update_attribute(:hidden, true)

    assert_raise ActiveRecord::RecordNotFound do
      Page.find_accessible(id)
    end

    assert_equal(@about_page, Page.find_accessible(id, :for => @arthur))
  end

  def test_should_respect_publication_status_of_ancestors
    weblog_archive = weblog_archives(:devcms_weblog_archive)
    weblog = weblogs(:henk_weblog)
    assert !weblog_archive.weblogs.find_accessible(:all, :for => @reader).blank?
    Node.root.update_attribute(:publication_end_date, 1.day.ago)
    assert weblog_archive.weblogs.find_accessible(:all, :for => @reader).blank?
    assert weblog_archive.weblogs.find_accessible(:all, :for => @arthur).blank?
  end

  def test_should_respect_publication_status_results
    weblog_archive = weblog_archives(:devcms_weblog_archive)
    weblog = weblogs(:henk_weblog)
    assert weblog_archive.weblogs.find_accessible(:all, :for => @reader).include?(weblog)
    weblog.update_attribute(:publication_end_date, 1.day.ago)
    assert !weblog_archive.weblogs.find_accessible(:all, :for => @reader).include?(weblog)
    assert !weblog_archive.weblogs.find_accessible(:all, :for => @arthur).include?(weblog)
  end

  def test_find_accessible_should_merge_conditions
    id = @about_page.id
    assert_equal @about_page, Page.find_accessible(:first, :conditions => {:title => @about_page.title})

    assert_raise ActiveRecord::RecordNotFound do
      Page.find_accessible(id, :conditions => ['title = ?', 'Does not exist'])
    end
  end

  def test_find_all_accessible_for_user
    assert Page.find(:all).reject{|page| page.node.is_hidden? || page.approved_version.nil? }.set_equals?(Page.find_accessible(:all, :for => users(:normal_user)))
    assert Page.find(:all).reject{|page| page.approved_version.nil? }.set_equals?(Page.find_accessible(:all, :for => @arthur))
  end

  def test_find_accessible_in_association
    weblog_archive = weblog_archives(:devcms_weblog_archive)
    weblog = weblogs(:henk_weblog)
    assert weblog_archive.weblogs.find_accessible(:all, :for => @reader).include?(weblog)
    weblog.node.update_attribute(:hidden, true)
    assert !weblog_archive.weblogs.find_accessible(:all, :for => @reader).include?(weblog)
    assert weblog_archive.weblogs.find_accessible(:all, :for => @arthur).include?(weblog)
  end

  def test_find_approved_versions
    page = create_page(:body => "Version 1")
    page.body = "Version 2"
    page.save_for_user(users(:editor))

    result = Page.find_accessible(:all, :approved_content => true, :page => {})
    assert_instance_of PagingEnumerator, result

    result.each do |p|
      assert_equal p.node.approved_content.body, p.body
    end
  end

  def test_should_find_accessible_on_node
    hidden_node = nodes(:hidden_section_node)
    nested_node = nodes(:nested_page_node)
    arthur = @arthur
    reader = users(:reader)
    normal_user = users(:normal_user)

    #default by id
    assert_equal @root_node, Node.find_accessible(@root_node.id)
    assert_equal @root_node, Node.find_accessible(@root_node.id, :for => :false)
    #by id for user
    assert_equal hidden_node, Node.find_accessible(hidden_node.id, :for => arthur)
    assert_equal nested_node, Node.find_accessible(nested_node.id, :for => arthur)
    assert_equal hidden_node, Node.find_accessible(hidden_node.id, :for => reader)
    assert_equal nested_node, Node.find_accessible(nested_node.id, :for => reader)

    assert_raise ActiveRecord::RecordNotFound do
      Node.find_accessible(hidden_node.id, :for => normal_user)
    end

    assert_raise ActiveRecord::RecordNotFound do
      Node.find_accessible(nested_node.id, :for => normal_user)
    end
    #all
    assert_equal Node.find(:all).reject{|node| node.is_hidden? || node.approved_content(:allow_nil => true).nil? || !node.published? }.size,
                  Node.find_accessible(:all).size
    assert_equal Node.find(:all).reject{|node| node.approved_content(:allow_nil => true).nil? }.size,
                  Node.find_accessible(:all, :for => arthur).size
    assert_equal Node.find(:all).reject{|node| (node.is_hidden? && reader.role_on(node).nil?) || node.approved_content(:allow_nil => true).nil? }.size,
                  Node.find_accessible(:all, :for => arthur).size
    #extra condition
    assert Node.find_accessible(:all, :for => arthur, :conditions => {:content_type => "image"}).all?{ |node| node.content === Image }
  end
  
  def test_should_not_find_inaccessible_nodes
    p = create_page
    p.node.update_attribute :hidden, true
    assert_nil Node.find_accessible(:first, :conditions => ['nodes.id = ?', p.node.id], :for => nil)
    assert_nil users(:editor).role_on(p.node)
    assert_nil Node.find_accessible(:first, :conditions => ['nodes.id = ?', p.node.id], :for => users(:editor))
    assert !p.node.is_accessible_for?(users(:editor))
  end

  protected
  def build_page(options = {})
    Page.new({ :title => "Page title", :preamble => "Ambule", :body => "Page body" }.merge(options))
  end

  def create_page(options = {})
    page = build_page({:parent => nodes(:root_section_node)}.merge(options))
    page.save
    page
  end
end
