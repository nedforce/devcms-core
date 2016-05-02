require File.expand_path('../../test_helper.rb', __FILE__)

class AttachmentTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  FIXTURE_FILE = 'files/ParkZandweerdMatrixplannen.doc'

  def test_should_create_attachment
    assert_attachment_difference { @attachment = create_attachment }

    f = File.open(File.dirname(__FILE__) + "/../fixtures/#{FIXTURE_FILE}")
    f.binmode
    assert_equal f.read, @attachment.file.file.read
  end

  test 'should require title' do
    assert_no_attachment_difference { create_attachment(title: nil) }
    assert_no_attachment_difference { create_attachment(title: '  ') }
  end

  def test_should_require_uploaded_file
    assert_no_attachment_difference { create_attachment(file: nil) }
  end

  def test_should_destroy_attachment
    assert_difference 'Attachment.count', -1 do
      attachments(:verslag_attachment).destroy
    end
  end

  def test_should_get_nil_extension_and_basename
    assert_nil attachments(:no_extension_attachment).extension
    assert_equal 'Sloeproeien', attachments(:no_extension_attachment).basename
  end

  def test_should_get_last_extension_and_basename
    assert_equal 'txt', attachments(:nested_extension_attachment).extension
    assert_equal 'snippet.css', attachments(:nested_extension_attachment).basename
  end

  def test_should_get_extension_and_basename
    assert_equal 'doc', attachments(:besluit_attachment).extension
    assert_equal '020301Besluitinformatiebeheer', attachments(:besluit_attachment).basename
  end

  def test_should_clean_filename
    attachment = create_attachment(filename: '2008.68936_Bijlage_Startnotitie_procesaanpak_Toekomstvisie_2030.pdf')
    assert_equal '2008-68936_Bijlage_Startnotitie_procesaanpak_Toekomstvisie_2030.pdf', attachment.filename
  end

  protected

  def assert_attachment_difference
    assert_difference 'Attachment.count' do
      yield
    end
  end

  def assert_no_attachment_difference
    assert_no_difference 'Attachment.count' do
      yield
    end
  end

  def create_attachment(options = {})
    Attachment.create({
      parent: nodes(:downloads_page_node),
      title: 'Park Zandweerd Matrix plannen',
      file: fixture_file_upload(FIXTURE_FILE, 'application/msword')
    }.merge(options))
  end
end
