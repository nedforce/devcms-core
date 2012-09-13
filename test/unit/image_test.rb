require File.expand_path('../../test_helper.rb', __FILE__)

class ImageTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true
  
  def test_should_create_image
    assert_difference('Image.count', 1) do
      i = create_image
      assert !i.new_record?, i.errors.full_messages.join("\n")
    end
  end
  
  def test_should_not_create_image_without_title
    assert_no_difference 'Image.count' do
      i = create_image(:title => nil)
      assert i.new_record? && i.errors[:title].any? 
    end
    
    assert_no_difference 'Image.count' do
      i = create_image(:title => "  ")
      assert i.new_record? && i.errors[:title].any? 
    end
  end
  
  def test_should_not_create_image_with_invalid_title
    assert_no_difference 'Image.count' do
      i = create_image(:title => 'F')
      assert i.new_record? && i.errors[:title].any? 
    end
  end

  def test_should_prepend_protocol_to_url 
    i = create_image(:url => 'www.example.com') 
    assert_equal 'http://www.example.com', i.url 
  end

  def test_should_not_prepend_protocol_to_url 
    i = create_image(:url => 'http://www.example.com') 
    assert_equal 'http://www.example.com', i.url 
  end 

  def test_should_not_prepend_protocol_to_url_if_nil 
    i = create_image(:url => nil) 
    assert_nil i.url 
  end 

  def test_should_not_prepend_protocol_to_url_for_https
    i = create_image(:url => 'https://www.example.com')
    assert_equal 'https://www.example.com', i.url
  end

  def test_should_return_set_alt_text
    i = create_image(:alt => "BOOM!")
    assert_equal i.alt, "BOOM!"
  end
  
  def test_should_return_nil_for_nil_alt_text
    i = create_image(:title => "BOOM!", :alt => nil)
    assert_equal nil, i.alt
  end
  
  def test_should_not_return_image_children_for_menu
    assert nodes(:about_page_node).children.accessible.shown_in_menu.empty?
  end
   
protected
  
  def create_image(options = {})
    Image.create({:parent => nodes(:devcms_news_item_node), :title => "Dit is een image.", :file => fixture_file_upload("files/test.jpg") }.merge(options))
  end
end
