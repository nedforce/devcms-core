require File.expand_path('../../test_helper.rb', __FILE__)

class LinkTest < ActiveSupport::TestCase
  def test_should_not_create_link_without_type
    assert_no_difference 'Link.count' do
      l = build_link
      l.type = nil
      l.valid?
      assert l.errors[:type].any?
    end
  end
  
  def test_should_not_create_link_with_invalid_type
    assert_no_difference 'Link.count' do
      l = build_link
      l.type = 'FooBarBazQuux'
      l.valid?      
      assert l.errors[:type].any?
    end
  end
  
protected
  
  def build_link(options = {})
    Link.new({:parent => nodes(:root_section_node), :title => "Dit is een link.", :description => "Geen fratsen!" }.merge(options))
  end
  
end