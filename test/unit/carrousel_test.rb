require File.expand_path('../../test_helper.rb', __FILE__)

class CarrouselTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true
  
  def setup
    @carrousel = create_carrousel
  end
  
  def test_should_create_carrousel
    assert !@carrousel.new_record?
  end

  def test_should_require_title
    assert_no_difference 'Carrousel.count' do
      carrousel = create_carrousel :title => nil
      assert carrousel.errors[:title].any?
    end
    
    assert_no_difference 'Carrousel.count' do
      carrousel = create_carrousel(:title => "  ")
      assert carrousel.errors[:title].any?
    end
  end

  def test_should_not_require_unique_title
    assert_difference 'Carrousel.count', 2 do
      2.times do
        carrousel = create_carrousel(:title => 'Non-unique title')
        assert !carrousel.errors[:title].any?
      end
    end
  end
  
  def test_should_update_carrousel
    assert_no_difference 'Carrousel.count' do
      assert @carrousel.update_attribute(:title, 'New title')
    end
  end
  
  def test_should_destroy_carrousel
    assert_difference "Carrousel.count", -1 do
      @carrousel.destroy
    end
  end
  
  def test_human_name_does_not_return_nil
    assert_not_nil Carrousel.human_name 
  end
  
  def test_should_add_carrousel_items
    @carrousel.associate_items([ nodes(:help_page_node).id, nodes(:devcms_news_item_node).id, nodes(:devcms_news_item_voor_vorige_maand_node).id], { nodes(:help_page_node).id => 'Help pagina', nodes(:devcms_news_item_node).id => 'Nieuws node' })
    assert @carrousel.save
    assert_equal 3, @carrousel.items_count
    assert_equal "Help pagina", @carrousel.carrousel_items.first.excerpt
    assert_nil @carrousel.carrousel_items.last.excerpt    
  end
  
  def test_should_select_one_current_item
    @carrousel.associate_items([ nodes(:help_page_node).id, nodes(:devcms_news_item_node).id, nodes(:devcms_news_item_voor_vorige_maand_node).id], { nodes(:help_page_node).id => 'Help pagina', nodes(:devcms_news_item_node).id => 'Nieuws node' })
    assert @carrousel.save
    assert_equal @carrousel.current_item, @carrousel.current_item    
  end
  
  def test_should_return_current_items_title_for_content_box
    @carrousel.associate_items([ nodes(:help_page_node).id, nodes(:devcms_news_item_node).id, nodes(:devcms_news_item_voor_vorige_maand_node).id], { nodes(:help_page_node).id => 'Help pagina', nodes(:devcms_news_item_node).id => 'Nieuws node' })
    assert @carrousel.save
    assert_equal @carrousel.custom_content_box_title, @carrousel.current_item.item.title
  end
  
  def test_should_set_default_display_time
    assert_equal 0, @carrousel.display_time
    assert_equal [0,'seconds'], @carrousel.human_display_time
  end
  
  def test_should_set_display_time
    carrousel = create_carrousel(:display_time => [5, 'hours'])
    assert_equal 300*60, carrousel.display_time
  end
  
  def test_should_cycle_current_item
    carrousel = create_carrousel(:display_time => [5, 'hours'])
    carrousel.associate_items([ nodes(:help_page_node).id, nodes(:devcms_news_item_node).id ])
    carrousel.save
    assert_equal nodes(:help_page_node), carrousel.find_current_carrousel_item.node
    assert_not_nil carrousel.reload.last_cycled
    
    carrousel.update_attribute(:last_cycled, 5.hours.ago)    
    assert_equal nodes(:devcms_news_item_node), carrousel.find_current_carrousel_item.node
    assert carrousel.reload.last_cycled > 5.minutes.ago

    carrousel.update_attribute(:last_cycled, 5.hours.ago)        
    assert_equal nodes(:help_page_node), carrousel.find_current_carrousel_item.node    
    assert carrousel.reload.last_cycled > 5.minutes.ago    
  end
  
  def test_should_properly_handle_empty_item_collection
    carrousel = create_carrousel(:display_time => [5, 'hours'])
    assert_nil carrousel.find_current_carrousel_item
  end
  
protected
  
  def create_carrousel(options = {})
    Carrousel.create({:parent => nodes(:root_section_node), :title => "Mijn content carrousel" }.merge(options))
  end

end
