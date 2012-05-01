require File.expand_path('../../test_helper.rb', __FILE__)

class WeblogArchiveTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  def setup
    @devcms_weblog_archive = weblog_archives(:devcms_weblog_archive)
  end

  def test_should_create_weblog_archive
    assert_difference 'WeblogArchive.count' do
      create_weblog_archive
    end
  end

  def test_should_require_title
    assert_no_difference 'WeblogArchive.count' do
      weblog_archive = create_weblog_archive(:title => nil)
      assert weblog_archive.errors[:title].any?
    end
  end

  def test_should_not_require_unique_title
    assert_difference 'WeblogArchive.count', 2 do
      2.times do
        weblog_archive = create_weblog_archive(:title => 'Non-unique title')
        assert !weblog_archive.errors[:title].any?
      end
    end
  end
  
  def test_should_update_weblog_archive
    assert_no_difference 'WeblogArchive.count' do
      @devcms_weblog_archive.title = 'New title'
      @devcms_weblog_archive.description = 'New description'
      assert @devcms_weblog_archive.save
    end
  end
  
  def test_should_destroy_weblog_archive
    assert_difference "WeblogArchive.count", -1 do
      @devcms_weblog_archive.destroy
    end
  end

  def test_find_weblogs_for_offset
    offsets = @devcms_weblog_archive.find_offsets
    
    offsets.each do |offset|
      assert !@devcms_weblog_archive.find_weblogs_for_offset(offset).empty?
    end
  end
  
  def test_find_first_and_last_weblog_for_offset
    offsets = @devcms_weblog_archive.find_offsets
    
    offsets.each do |offset|
      first, second = @devcms_weblog_archive.find_first_and_last_weblog_for_offset(offset)
      assert_not_nil first
      assert_not_nil second
    end
  end
  
  def test_find_offsets
    default_offset = WeblogArchive::DEFAULT_OFFSET
    offsets = @devcms_weblog_archive.find_offsets
    number_of_weblogs = @devcms_weblog_archive.weblogs.size
    
    assert offsets.first == 0
    assert offsets.last <= number_of_weblogs && number_of_weblogs <= (offsets.last + default_offset)
    
    offsets.each do |offset|
      assert_equal 0, offset % default_offset
    end
  end

  def test_parse_offset
    default_offset = WeblogArchive::DEFAULT_OFFSET

    (-(3 * default_offset)..(3 * default_offset)).to_a.each do |offset|
      if offset < 0
        assert_equal 0, WeblogArchive.parse_offset(offset)
      else
        parsed_offset = WeblogArchive.parse_offset(offset)
        assert parsed_offset <= offset && offset <= (parsed_offset + default_offset)
      end
    end
  end

  def test_has_weblog_for_user?
    @weblog = @devcms_weblog_archive.weblogs.first
    assert @devcms_weblog_archive.has_weblog_for_user?(@weblog.user)
    @weblog.destroy
    assert !@devcms_weblog_archive.reload.has_weblog_for_user?(@weblog.user)
  end

protected

  def create_weblog_archive(options = {})
    WeblogArchive.create({:parent => nodes(:root_section_node), :title => 'DevCMS weblogs, the best there are!', :description => 'Enjoy!'}.merge(options))
  end
end
