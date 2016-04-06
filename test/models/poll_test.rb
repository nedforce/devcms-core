require File.expand_path('../../test_helper.rb', __FILE__)

# Unit tests for the +Poll+ model.
class PollTest < ActiveSupport::TestCase
  setup do
    @hc_poll = polls(:healthcare_poll)
  end

  test 'should create poll' do
    assert_difference 'Poll.count', 1 do
      poll = Poll.create(parent: nodes(:root_section_node), title: 'New poll')
      refute poll.new_record?
    end
  end

  test 'should require title' do
    assert_no_difference 'Poll.count' do
      [nil, '  '].each do |title|
        poll = Poll.create(parent: nodes(:root_section_node), title: title)
        assert poll.new_record?
        assert poll.errors[:title].any?
      end
    end
  end

  test 'should update poll' do
    assert_no_difference 'Poll.count' do
      @hc_poll.title = 'New title'
      assert @hc_poll.save
    end
  end

  test 'should destroy poll' do
    assert_difference 'Poll.count', -1 do
      @hc_poll.destroy
    end
  end

  test 'should return active question' do
    assert_equal poll_questions(:hc_question_1), @hc_poll.active_question
  end

  test 'should return nil without active question' do
    @hc_poll.poll_questions.each { |pq| pq.update_attribute(:active, false) }
    assert_nil @hc_poll.active_question
  end
end
