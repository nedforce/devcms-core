require File.expand_path('../../test_helper.rb', __FILE__)

class CarrouselItemTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  setup do
    @carrousel = create_carrousel
    @carrousel_item = create_carrousel_item @carrousel
  end

  test 'should create carrousel item' do
    refute @carrousel_item.new_record?
  end

  test 'should require item' do
    assert_no_difference 'CarrouselItem.count' do
      carrousel_item = create_carrousel_item(@carrousel, item: nil)
      assert carrousel_item.errors[:item].any?
    end
  end

  test 'should return approved content' do
    assert_equal pages(:about_page), @carrousel_item.item
  end

  test 'should return title' do
    assert_equal pages(:about_page).title, @carrousel_item.title
  end

  protected

  def create_carrousel(options = {})
    Carrousel.create({
      parent: nodes(:root_section_node),
      title: 'Mijn content carrousel'
    }.merge(options))
  end

  def create_carrousel_item(carrousel, options = {})
    carrousel.carrousel_items.create({
      item: pages(:about_page),
      excerpt: 'Excerpt'
    }.merge(options))
  end
end
