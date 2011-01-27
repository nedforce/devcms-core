require File.dirname(__FILE__) + '/../test_helper'

class LinkTest < ActiveSupport::TestCase
  def test_should_not_create_link_without_type
    assert_no_difference 'Link.count' do
      l = create_link
      assert l.errors.on_base
    end
  end
  
  def test_should_not_create_link_with_invalid_type
    assert_no_difference 'Link.count' do
      l = create_link(:type => 'FooBarBazQuux')
      assert l.errors.on_base
    end
  end
  
protected
  
  def create_link(options = {})
    Link.create({:parent => nodes(:root_section_node), :title => "Dit is een link.", :description => "Geen fratsen!" }.merge(options))
  end
  
end