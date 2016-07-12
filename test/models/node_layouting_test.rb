require File.expand_path('../../test_helper.rb', __FILE__)

class NodeLayoutingTest < ActiveSupport::TestCase
  setup do
    @site = Site.create(title: 'sub_site', domain: 'sub.test.local.dev', parent: Node.root)
  end

  test 'should set to default for sites' do
    assert_equal Node.root.layout, @site.node.layout
    assert_equal 'default', @site.node.layout_variant
    assert_equal Hash.new, @site.node.layout_configuration
  end

  test 'should return first parent containing headers' do
    assert_equal nodes(:devcms_weblog_archive_node), nodes(:henk_weblog_post_one_node).header_container
    assert_equal nodes(:devcms_weblog_archive_node), nodes(:devcms_weblog_archive_node).header_container
    assert_equal nodes(:root_section_node), nodes(:about_page_node).header_container
  end

  test 'should return containing site as header container with no headers' do
    assert_equal nodes(:sub_site_section_node), nodes(:yet_another_page_node).header_container
  end

  test 'should not inherit for subsites if appropriate setting is set' do
    section = Section.create title: 'section', parent: Node.root
    original_setting = Settler.subsites_do_not_inherit.value

    Settler.subsites_do_not_inherit.update_attribute :value, 'false'
    assert @site.node.inherit_content?
    assert section.node.inherit_content?
    Settler.subsites_do_not_inherit.update_attribute :value, 'true'
    refute @site.node.inherit_content?
    assert section.node.inherit_content?

    Settler.subsites_do_not_inherit.update_attribute :value, original_setting
  end
end
