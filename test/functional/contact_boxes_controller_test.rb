require File.dirname(__FILE__) + '/../test_helper'

class ContactBoxesControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  def setup
    @root_node = nodes(:root_section_node)
    @contact_box = create_contact_box
  end

  def test_should_show_contact_box
    # How can we test this without Html::Test complaining about the route not existing?
    # get :show, :id => @contact_box.id
    # assert_response :redirect
    # assert_redirected_to '/contact'
  end

  def test_should_render_404_if_not_found
    get :show, :id => -1
    assert_response :not_found
  end

  protected

  def create_contact_box(options = {})
    ContactBox.create({:parent => @root_node,
      :title => 'Contactbox',
      :contact_information => 'Contactinformatie',
      :default_text => 'Standaardtekst'
    }.merge(options))
  end
end
