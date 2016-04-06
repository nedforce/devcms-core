require File.expand_path('../../test_helper.rb', __FILE__)

# Unit tests for the +ExternalLink+ model.
class ExternalLinkTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  setup do
    @external_link = links(:external_link)
  end

  test 'should create external link' do
    assert_difference 'ExternalLink.count', 1 do
      create_external_link
    end
  end

  test 'should create external https link' do
    https_url = 'https://www.nedforce.com'

    assert_difference 'ExternalLink.count', 1 do
      external_link = create_external_link(url: https_url)
      assert_equal external_link.url, https_url
    end
  end

  test 'should require url' do
    assert_no_difference 'ExternalLink.count' do
      external_link = create_external_link(url: nil)
      assert external_link.errors[:url].any?
    end
  end

  def test_should_strip_http_for_url_alias
    link = create_external_link(title: '', description: '', url: 'http://www.example.com')
    assert_equal 'www.example.com', link.path_for_url_alias(link.node)
  end

  def test_should_set_description_and_title_to_nil_if_blank
    l1 = create_external_link(title: '', description: '')
    refute l1.new_record?
    assert_nil l1.title
    assert_nil l1.description
    l2 = create_external_link(title: nil, description: nil)
    refute l2.new_record?
    l2.update_attributes(user: users(:arthur), title: '', description: '')
    assert_nil l2.title
    assert_nil l2.description
  end

  def test_should_require_valid_url
    [' ', 'foo', 'http://www. foo.com', 'http://www.foo_bar.com', 'http://f.o.o'].each do |url|
      assert_no_difference 'ExternalLink.count' do
        external_link = create_external_link(url: url)
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

  test 'should not require unique title' do
    assert_difference 'ExternalLink.count', 2 do
      2.times do
        external_link = create_external_link(title: 'Non-unique title')
        refute external_link.errors[:title].any?
      end
    end
  end

  test 'should update external link' do
    assert_no_difference 'ExternalLink.count' do
      @external_link.title = 'New title'
      @external_link.description = 'New body'
      @external_link.url = 'http://www.disney.com'

      assert @external_link.save(user: users(:arthur))
    end
  end

  test 'should destroy external link' do
    assert_difference 'ExternalLink.count', -1 do
      @external_link.destroy
    end
  end

  test 'should create numerical external link' do
    assert_difference 'ExternalLink.count' do
      create_external_link(url: 'http://123.123.123.123/TakeSurvey.aspx?SurveyID=92KL9l2')
    end
  end

  protected

  def create_external_link(options = {})
    ExternalLink.create({
      parent: nodes(:root_section_node),
      title: 'This is an external link',
      description: 'Geen fratsen!',
      url: 'http://www.google.com'
    }.merge(options))
  end
end
