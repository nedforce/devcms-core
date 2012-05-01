
require File.expand_path('../../test_helper.rb', __FILE__)

class NodeLayoutingTest < ActiveSupport::TestCase
  
  def test_should_set_to_default_for_sites
    site = Site.create(:title => "sub_site", :domain => "sub.test.local.dev", :parent => Node.root)
    assert_equal Node.root.layout, site.node.layout
    assert_equal "default", site.node.layout_variant
    assert_equal Hash.new, site.node.layout_configuration
  end
  
end
