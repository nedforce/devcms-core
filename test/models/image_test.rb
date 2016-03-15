require File.expand_path('../../test_helper.rb', __FILE__)

# Unit tests for the +Image+ model.
class ImageTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  test 'should create image' do
    assert_difference('Image.count', 1) do
      image = create_image
      assert !image.new_record?, image.errors.full_messages.join("\n")
    end
  end

  test 'should require valid title' do
    assert_no_difference 'Image.count' do
      image1 = create_image(title: nil)
      assert image1.new_record?
      assert image1.errors[:title].any?

      image2 = create_image(title: '  ')
      assert image2.new_record?
      image2.errors[:title].any?
    end
  end

  test 'should prepend protocol to url' do
    image = create_image(url: 'www.example.com')
    assert_equal 'http://www.example.com', image.url
  end

  test 'should not prepend protocol to url' do
    image = create_image(url: 'http://www.example.com')
    assert_equal 'http://www.example.com', image.url
  end

  test 'should not prepend protocol to url if nil' do
    image = create_image(url: nil)
    assert_nil image.url
  end

  test 'should not prepend protocol to url for https' do
    image = create_image(url: 'https://www.example.com')
    assert_equal 'https://www.example.com', image.url
  end

  test 'should return set alt text' do
    image = create_image(alt: 'BOOM!')
    assert_equal image.alt, 'BOOM!'
  end

  test 'should return nil for nil alt text' do
    image = create_image(title: 'BOOM!', alt: nil)
    assert_nil image.alt
  end

  test 'should not return image children for menu' do
    assert nodes(:about_page_node).children.accessible.shown_in_menu.empty?
  end

  protected

  def create_image(options = {})
    Image.create({
      parent: nodes(:devcms_news_item_node),
      title: 'This is an image',
      file: fixture_file_upload('files/test.jpg')
    }.merge(options))
  end
end
