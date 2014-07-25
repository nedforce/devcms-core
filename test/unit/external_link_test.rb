require File.expand_path('../../test_helper.rb', __FILE__)

class ExternalLinkTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  def setup
    @external_link = links(:external_link)
  end

  def test_should_create_external_link
    assert_difference 'ExternalLink.count', 1 do
      create_external_link
    end
  end

  def test_should_create_external_link_with_https
    assert_difference 'ExternalLink.count', 1 do
      external_link = create_external_link(:url => 'https://www.google.com')
      assert_equal external_link.url, 'https://www.google.com'
    end
  end

  def test_should_require_url
    assert_no_difference 'ExternalLink.count' do
      external_link = create_external_link(:url => nil)
      assert external_link.errors[:url].any?
    end
  end

  def test_should_strip_http_for_url_alias
    link = create_external_link(:title => '', :description => '', :url => 'http://www.example.com')
    assert_equal 'www.example.com', link.path_for_url_alias(link.node)
  end

  def test_should_set_description_and_title_to_nil_if_blank
    l1 = create_external_link(:title => '', :description => '')
    assert !l1.new_record?
    assert_equal nil, l1.title
    assert_equal nil, l1.description
    l2 = create_external_link(:title => nil, :description => nil)
    assert !l2.new_record?
    l2.update_attributes(:user => users(:arthur), :title => '', :description => '')
    assert_equal nil, l2.title
    assert_equal nil, l2.description
  end

  def test_should_require_valid_url
    [' ', 'blaat', 'http://www. blaat.nl', 'http://www.bla_at.nl', 'http://a.b.c'].each do |url|
      assert_no_difference 'ExternalLink.count' do
        external_link = create_external_link(:url => url)
        assert external_link.errors[:url].any?
      end
    end
  end

  def test_content_title_should_return_title_if_title_exists
    assert_equal @external_link.title, @external_link.content_title
  end

  def test_content_title_should_return_url_if_no_title_exists
    @external_link.update_attribute(:title, nil)
    assert_equal @external_link.url, @external_link.content_title
  end

  def test_should_not_require_unique_title
    assert_difference 'ExternalLink.count', 2 do
      2.times do
        external_link = create_external_link(:title => 'Non-unique title')
        assert !external_link.errors[:title].any?
      end
    end
  end

  def test_should_update_external_link
    assert_no_difference 'ExternalLink.count' do
      @external_link.title = 'New title'
      @external_link.description = 'New body'
      @external_link.url = 'http://www.disney.com'
      assert @external_link.save(:user => users(:arthur))
    end
  end

  def test_should_destroy_external_link
    assert_difference "ExternalLink.count", -1 do
      @external_link.destroy
    end
  end

  def test_should_create_numerical_external_link
    assert_difference "ExternalLink.count" do
      create_external_link(:url => "http://123.123.123.123/TakeSurvey.aspx?SurveyID=92KL9l2")
    end
  end

protected

  def create_external_link(options = {})
    ExternalLink.create({ :parent => nodes(:root_section_node), :title => 'Dit is een external link.', :description => 'Geen fratsen!', :url => 'http://www.google.com' }.merge(options))
  end
end
