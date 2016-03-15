require File.expand_path('../../test_helper.rb', __FILE__)

# Functional tests for the +NodesController+.
class NodesControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  setup do
    @root_section_node = nodes(:root_section_node)
    @root_section_node.content.set_frontpage!(@root_section_node)
  end

  test 'should get atom changes for self and children' do
    get :changes, format: 'atom', id: sections(:root_section).node.id
    assert_response :success
    assert assigns(:nodes).size > 1
  end

  test 'should get rss changes for self and children' do
    get :changes, format: 'rss', id: sections(:root_section).node.id
    assert_response :success
    assert assigns(:nodes).size > 1
  end

  test 'should get atom changes for self if changed feed toggle is true' do
    assert sections(:economie_section).node.update_attribute(:has_changed_feed, true)

    get :changes, format: 'atom', id: sections(:economie_section).node.id
    assert_response :success
  end

  test 'should get rss changes for self if changed feed toggle is true' do
    assert sections(:economie_section).node.update_attribute(:has_changed_feed, true)

    get :changes, format: 'rss', id: sections(:economie_section).node.id
    assert_response :success
  end

  test 'should get atom changes for page if changed feed toggle is true' do
    pages(:help_page).node.update_attribute(:has_changed_feed, true)
    get :changes, format: 'atom', id: pages(:help_page).node.id
    assert assigns(:nodes).size == 1
  end

  test 'should get rss changes for page if changed feed toggle is true' do
    pages(:help_page).node.update_attribute(:has_changed_feed, true)
    get :changes, format: 'rss', id: pages(:help_page).node.id
    assert assigns(:nodes).size == 1
  end

  test 'should not get atom changes for self if changes feed toggle is false' do
    get :changes, format: 'atom', id: pages(:help_page).node.id
    assert_response :not_found
  end

  test 'should not get rss changes for self if changes feed toggle is false' do
    get :changes, format: 'rss', id: pages(:help_page).node.id
    assert_response :not_found
  end
end
