require File.expand_path('../../test_helper.rb', __FILE__)

# Unit tests for the +PollOption+ model.
class PollOptionTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  setup do
    @q = poll_questions(:hc_question_1)
    @o = poll_options(:hc_question_1_option_1)
  end

  test 'should create poll options' do
    assert_difference 'PollOption.count', 2 do
      PollOption.create(poll_question: @q, text: 'Ja')
      PollOption.create(poll_question: @q, text: 'Nee')
    end
  end

  test 'should require text' do
    @o.update_attributes(text: nil)
    assert @o.errors[:text].any?
    assert !@o.reload.text.blank?
  end

  test 'should not allow duplicate options' do
    assert_no_difference 'PollOption.count' do
      o = @q.poll_options.create(text: @o.text)
      assert o.errors[:text].any?
    end
  end

  test 'should cast vote' do
    assert_difference '@o.reload.number_of_votes', 1 do
      @o.vote!
    end
  end

  test 'should not cast vote if question is inactive' do
    @q.update_attribute(:active, false)
    assert_no_difference '@o.reload.number_of_votes' do
      @o.vote!
    end
  end

  test 'should return percentage of votes' do
    @o2 = poll_options(:hc_question_1_option_2)

    [@o, @o2].each do |o|
      16.times { o.vote! }
    end

    assert_equal 50, @o.reload.percentage_of_votes
    assert_equal 50, @o2.reload.percentage_of_votes
  end

  test 'should return 0 percent for no votes' do
    PollOption.update_all('number_of_votes = 0')
    assert_equal 0, @o.percentage_of_votes
  end
end
