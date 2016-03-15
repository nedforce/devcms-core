require File.expand_path('../../test_helper.rb', __FILE__)

class LinkTest < ActiveSupport::TestCase
  def test_should_not_create_link_without_type
    assert_no_difference 'Link.count' do
      link = build_link
      link.type = nil
      assert !link.valid?
      assert link.errors[:type].any?
    end
  end

  def test_should_not_create_link_with_invalid_type
    assert_no_difference 'Link.count' do
      link = build_link
      link.type = 'FooBarBazQuux'
      assert !link.valid?
      assert link.errors[:type].any?
    end
  end

protected

  def build_link(options = {})
    Link.new({ :parent => nodes(:root_section_node), :title => 'This is a link', :description => 'Geen fratsen!' }.merge(options))
  end
end
