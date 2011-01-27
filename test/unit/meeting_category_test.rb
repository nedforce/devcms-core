require File.dirname(__FILE__) + '/../test_helper'

class MeetingCategoryTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true
  
  def setup
    @meeting_category = meeting_categories(:gemeenteraad_meetings)
  end
  
  def test_should_create_meeting_category
    assert_difference 'MeetingCategory.count' do
      create_meeting_category
    end
  end

  def test_should_require_name
    assert_no_difference 'MeetingCategory.count' do
      meeting_category = create_meeting_category(:name => nil)
      assert meeting_category.errors.on(:name)
    end
  end
  
  def test_should_require_unique_name
    assert_no_difference 'MeetingCategory.count' do
      meeting_category = create_meeting_category(:name => @meeting_category.name)
      assert meeting_category.errors.on(:name)
    end
  end
  
  def test_should_update_meeting_category
    assert_no_difference 'MeetingCategory.count' do
      @meeting_category.name = 'New name'
      assert @meeting_category.save
    end
  end
  
  def test_should_destroy_meeting_category
    assert_difference "MeetingCategory.count", -1 do
      @meeting_category.destroy
    end
  end

  def test_find_or_new_by_name
    mc1 = create_meeting_category
    
    assert_no_difference 'MeetingCategory.count' do
      assert_equal mc1, MeetingCategory.find_or_new_by_name(mc1.name)
      mc2 = MeetingCategory.find_or_new_by_name('doesnotexist')
      assert mc2.new_record?
      assert_equal 'doesnotexist', mc2.name
    end
  end
  
protected
  
  def create_meeting_category(options = {})
    MeetingCategory.create({ :name => 'Foobarbazquux' }.merge(options))
  end
end
