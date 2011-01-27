require File.dirname(__FILE__) + '/../test_helper'

class PollOptionTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  def setup
    @q = poll_questions(:hc_question_1)
    @o = poll_options(:hc_question_1_option_1)
  end

  def test_should_create_poll_options
    assert_difference 'PollOption.count', 2 do
      PollOption.create(:poll_question => @q, :text => 'Ja')
      PollOption.create(:poll_question => @q, :text => 'Nee')
    end
  end

  def test_should_require_text
    @o.update_attributes(:text => nil)
    assert @o.errors.on(:text)
    assert !@o.reload.text.blank?
  end

  def test_should_not_allow_duplicate_options
    assert_no_difference 'PollOption.count' do
      o = @q.poll_options.create(:text => @o.text)
      assert o.errors.on(:text)
    end
  end

  def test_should_cast_vote
    assert_difference '@o.reload.number_of_votes', 1 do
      @o.vote!
    end
  end

  def test_should_not_cast_vote_if_question_is_inactive
    @q.update_attribute(:active, false)
    assert_no_difference '@o.reload.number_of_votes' do
      @o.vote!
    end
  end

  def test_should_return_percentage_of_votes
    @o2 = poll_options(:hc_question_1_option_2)

    [ @o, @o2 ].each do |o|
      16.times { o.vote! }
    end

    assert_equal 50, @o.percentage_of_votes
    assert_equal 50, @o2.percentage_of_votes
  end

  def test_should_return_0_percent_for_no_votes
    PollOption.update_all('number_of_votes = 0')
    assert_equal 0, @o.percentage_of_votes
  end

end