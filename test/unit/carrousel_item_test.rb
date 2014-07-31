require File.expand_path('../../test_helper.rb', __FILE__)

class CarrouselItemTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  def setup
    @carrousel = create_carrousel
    @carrousel_item = create_carrousel_item @carrousel
  end

  def test_should_create_carrousel_item
    assert !@carrousel_item.new_record?
  end

  def test_should_require_item
    assert_no_difference 'CarrouselItem.count' do
      carrousel_item = create_carrousel_item(@carrousel, :item => nil)
      assert carrousel_item.errors[:item].any?
    end
  end

  def test_should_return_approved_content
    assert_equal pages(:about_page), @carrousel_item.item
  end

  def test_should_return_title
    assert_equal pages(:about_page).title, @carrousel_item.title
  end

protected

  def create_carrousel(options = {})
    Carrousel.create({ :parent => nodes(:root_section_node), :title => 'Mijn content carrousel' }.merge(options))
  end

  def create_carrousel_item(carrousel, options = {})
    carrousel.carrousel_items.create({ :item => pages(:about_page), :excerpt => 'Excerpt' }.merge(options))
  end
end
