require File.dirname(__FILE__) + '/../test_helper'

class SiteTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  def setup
    @root_section = sections(:root_section)
    @sub_site_section = sections(:sub_site_section)
  end

  def test_should_create_site
    assert_difference 'Site.count', 1 do
      site = create_site
      assert !site.new_record?, site.errors.full_messages
    end
  end

  def test_should_validate_domain_if_given
    assert_no_difference 'Site.count' do
      site = create_site :domain => 'qlu'
      assert site.errors.on(:domain)
    end
  end

  def test_should_not_create_site_when_parent_is_not_root
    assert_no_difference 'Site.count' do
      site = create_site :parent => @sub_site_section.node
      assert site.errors.on_base
    end
  end
  
  def test_should_have_case_insensitive_unique_urls
    assert_difference 'Site.count', 1 do
      site = create_site
      assert !site.new_record?
      site = create_site :domain => 'WwW.nEdFoRcE.nL'
      assert site.errors.on(:domain)
    end
  end
  
  def test_should_set_default_layout
    site = create_site
    assert_equal Node.root.layout, site.node.layout
    assert_equal 'default', site.node.layout_variant
    assert_equal Hash.new, site.node.layout_configuration
  end

protected

  def create_site(options = {})
    Site.create({ :parent => @root_section.node, :title => 'site', :domain => 'www.nedforce.nl' }.merge(options))
  end

end
