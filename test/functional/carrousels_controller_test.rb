require File.dirname(__FILE__) + '/../test_helper'

class CarrouselsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true
  
  def setup
    @carrousel = create_carrousel
  end
  
  def test_should_show_carrousel
    get :show, :id => @carrousel.id
    assert_response :success
    assert assigns(:carrousel)
    assert_equal @carrousel.node, assigns(:node)
  end
  
  def test_should_not_show_unpublished_carrousel
    carroussel = create_carrousel :publication_start_date => 1.day.from_now
    get :show, :id => carroussel.id
    assert_response :not_found
  end
  
  def test_should_cycle_carrousel_items
    @carrousel.update_attribute(:display_time, [5, 'hours'])
    item1 = create_carrousel_item(@carrousel)
    item2 = create_carrousel_item(@carrousel, :item => news_items(:devcms_news_item), :position => 1)
    
    get :show, :id => @carrousel.id
    assert_response :success
    assert_not_nil assigns(:carrousel).reload.last_cycled
    assert_equal item1.item, assigns(:carrousel_item).item  

    @carrousel.update_attribute(:last_cycled, 4.hours.ago)    
    get :show, :id => @carrousel.id
    assert_response :success
    assert_not_nil assigns(:carrousel).last_cycled
    assert_equal item1.item, assigns(:carrousel_item).item          
    
    @carrousel.update_attribute(:last_cycled, 5.hours.ago)
    get :show, :id => @carrousel.id
    assert_response :success
    assert_equal item2.item, assigns(:carrousel_item).item    
    
    @carrousel.update_attribute(:last_cycled, 5.hours.ago)
    get :show, :id => @carrousel.id
    assert_response :success
    assert_equal item1.item, assigns(:carrousel_item).item      
  end
  
protected
  
  def create_carrousel(options = {})
    Carrousel.create({:parent => nodes(:root_section_node), :publication_start_date => 1.day.ago, :title => "Mijn content carrousel" }.merge(options))
  end  
  
  def create_carrousel_item(carrousel, options = {})
    carrousel.carrousel_items.create({ :item => pages(:about_page), :excerpt => 'Excerpt', :position => 0 }.merge(options))
  end    
end
