require File.expand_path('../../test_helper.rb', __FILE__)

class SiteTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  setup do
    @root_section     = sections(:root_section)
    @sub_site_section = sections(:sub_site_section)
  end

  test 'should create site' do
    assert_difference 'Site.count', 1 do
      site = create_site
      refute site.new_record?, site.errors.full_messages.to_sentence
    end
  end

  test 'should validate domain if given' do
    assert_no_difference 'Site.count' do
      site = create_site domain: 'qlu'
      assert site.errors[:domain].any?
    end
  end

  test 'should not create site when parent is not root' do
    assert_no_difference 'Site.count' do
      site = create_site parent: @sub_site_section.node
      assert site.errors[:base].any?
    end
  end

  test 'should have case insensitive unique domains' do
    assert_difference 'Site.count', 1 do
      site = create_site
      refute site.new_record?
      site = create_site domain: 'WwW.nEdFoRcE.nL'
      assert site.errors[:domain].any?
    end
  end

  test 'should set default layout' do
    site = create_site
    assert_equal Node.root.layout, site.node.layout
    assert_equal 'default', site.node.layout_variant
    assert_equal({}, site.node.layout_configuration)
  end

  protected

  def create_site(options = {})
    Site.create({
      parent: @root_section.node,
      title:  'site',
      domain: 'www.nedforce.nl'
    }.merge(options))
  end
end
