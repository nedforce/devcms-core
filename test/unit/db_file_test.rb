require File.dirname(__FILE__) + '/../test_helper'

class DbFileTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true
  
  include AttachmentTestHelper
  
  def test_should_create_db_file
    assert_difference 'DbFile.count' do
      create_db_file
    end
  end
  
  def test_should_require_loid
    assert_no_difference 'DbFile.count' do
      create_db_file(:loid => nil)
    end
  end
  
  protected
    def create_db_file(options = {})
      DbFile.create({ :loid => 0 }.merge(options))
    end
end
