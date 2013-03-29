require File.expand_path('../../test_helper.rb', __FILE__)

class SectionsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true
  
  def setup
    @root_section_node = nodes(:root_section_node)
    
    @root_section_node.content.set_frontpage!(@root_section_node)
  end
  
  def test_should_show_section
    get :show, :id => sections(:root_section).id
    assert_response :success
  end

  def test_should_show_site_piwik_script
    assert sections(:root_section).update_column :piwik_site_id, 'PIWIKCODE'
    get :show, :id => sections(:root_section).id
    assert response.body.include?('PIWIKCODE')
  end
  
end
