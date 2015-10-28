require File.expand_path('../../test_helper.rb', __FILE__)

class MeetingCategoryTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  setup do
    @meeting_category = meeting_categories(:gemeenteraad_meetings)
  end

  test 'should create meeting category' do
    assert_difference 'MeetingCategory.count' do
      create_meeting_category
    end
  end

  test 'should require name' do
    assert_no_difference 'MeetingCategory.count' do
      meeting_category = create_meeting_category(name: nil)
      assert meeting_category.errors[:name].any?
    end
  end

  test 'should require unique name' do
    assert_no_difference 'MeetingCategory.count' do
      meeting_category = create_meeting_category(name: @meeting_category.name)
      assert meeting_category.errors[:name].any?
    end
  end

  test 'should update meeting category' do
    assert_no_difference 'MeetingCategory.count' do
      @meeting_category.name = 'New name'
      assert @meeting_category.save
    end
  end

  test 'should destroy meeting category' do
    assert_difference 'MeetingCategory.count', -1 do
      @meeting_category.destroy
    end
  end

  test 'should find or new by name' do
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
    MeetingCategory.create({ name: 'Foobarbazquux' }.merge(options))
  end
end
