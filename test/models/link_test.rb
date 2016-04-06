require File.expand_path('../../test_helper.rb', __FILE__)

class LinkTest < ActiveSupport::TestCase
  test 'should not create link without type' do
    assert_no_difference 'Link.count' do
      link = build_link
      link.type = nil
      refute link.valid?
      assert link.errors[:type].any?
    end
  end

  test 'should not create link with invalid type' do
    assert_no_difference 'Link.count' do
      link = build_link
      link.type = 'FooBarBazQuux'
      refute link.valid?
      assert link.errors[:type].any?
    end
  end

  protected

  def build_link(options = {})
    Link.new({
      parent: nodes(:root_section_node),
      title: 'This is a link',
      description: 'Geen fratsen!'
    }.merge(options))
  end
end
