require File.dirname(__FILE__) + '/../test_helper'

class NodeExpirationTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = false
  
  def test_expirable_content_types
    assert Node.expirable_content_types.is_a?(Array)
    assert_equal ["Page"], Node.expirable_content_types
  end
  
  def test_should_set_expires_on_to_default
    node = create_page.node
    assert node.expirable?
    assert node.expiration_required?
    node.save
    assert_not_nil node.expires_on
    assert_equal Settler[:default_expiration_time], (node.expires_on - Date.today).to_i
  end
  
  def test_should_set_expires_on_with_versioning
    page = pages(:editor_section_page)
    node = page.node
    node.update_attribute :expires_on, 2.days.ago
    page.title = "Version 2"
    page.expires_on = 5.days.from_now.to_date

    assert page.valid?, page.errors.full_messages.to_sentence
    assert page.save(:user => users(:editor)), page.errors.full_messages.to_sentence
    
    node.reload
    
    assert_not_nil node.expires_on
    assert_equal 5.days.from_now.to_date, node.expires_on.to_date
  end
  
  def test_should_not_allow_expiration_date_longer_than_default_period
    page = build_page(:expires_on => (Date.today + Settler[:default_expiration_time].days + 1.week))
    assert !page.node.valid?
    assert page.new_record?
  end
  
protected

  def build_page(options = {})
    Page.new({ :parent => nodes(:root_section_node), :title => "Page title", :preamble => "Ambule", :body => "Page body" }.merge(options))
  end

  def create_page(options = {})
    page = build_page(options)
    page.save
    page
  end

end

