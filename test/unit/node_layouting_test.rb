
require File.expand_path('../../test_helper.rb', __FILE__)

class NodeLayoutingTest < ActiveSupport::TestCase
  
  def test_should_set_to_default_for_sites
    site = Site.create(:title => "sub_site", :domain => "sub.test.local.dev", :parent => Node.root)
    assert_equal Node.root.layout, site.node.layout
    assert_equal "default", site.node.layout_variant
    assert_equal Hash.new, site.node.layout_configuration
  end

  def test_should_return_first_parent_containing_headers
    assert_equal nodes(:devcms_weblog_archive_node), nodes(:henk_weblog_post_one_node).header_container
    assert_equal nodes(:devcms_weblog_archive_node), nodes(:devcms_weblog_archive_node).header_container
    assert_equal nodes(:root_section_node), nodes(:about_page_node).header_container
  end

  def test_should_return_containing_site_as_header_container_with_no_headers
    assert_equal nodes(:sub_site_section_node), nodes(:yet_another_page_node).header_container
  end
  
end
