require File.expand_path('../../test_helper.rb', __FILE__)

# Functional tests for the +SectionsController+.
class SectionsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  setup do
    @root_section_node = nodes(:root_section_node)

    @root_section_node.content.set_frontpage!(@root_section_node)
  end

  test 'should show section' do
    get :show, id: sections(:root_section).id

    assert_response :success
  end

  test 'should show site piwik script' do
    assert sections(:root_section).update_column :piwik_site_id, 'PIWIKCODE'
    get :show, id: sections(:root_section).id

    assert response.body.include?('PIWIKCODE')
  end
end
