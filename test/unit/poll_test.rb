require File.dirname(__FILE__) + '/../test_helper'

class PollTest < ActiveSupport::TestCase
  
  def setup
    @hc_poll = polls(:healthcare_poll)
  end
  
  def test_should_create_poll
    assert_difference 'Poll.count', 1 do
      poll = Poll.create(:parent => nodes(:root_section_node), :title => 'Economie poll')
      assert !poll.new_record?
    end
  end
  
  def test_should_require_title
    assert_no_difference 'Poll.count' do
      poll = Poll.create(:parent => nodes(:root_section_node), :title => nil)
      assert poll.new_record?
      assert poll.errors.on(:title)
    end
    
    assert_no_difference 'Poll.count' do
      poll = Poll.create(:parent => nodes(:root_section_node), :title => "  ")
      assert poll.new_record?
      assert poll.errors.on(:title)
    end
  end
  
  def test_should_update_poll
    assert_no_difference 'Poll.count' do
      @hc_poll.title = 'New title'
      assert @hc_poll.send(:save)
    end
  end
  
  def test_should_destroy_poll
    assert_difference "Poll.count", -1 do
      @hc_poll.destroy
    end
  end
  
  def test_should_return_active_question
    assert_equal poll_questions(:hc_question_1), @hc_poll.active_question
  end
  
  def test_should_return_nil_without_active_question
    @hc_poll.poll_questions.each{|pq| pq.update_attribute(:active, false) }
    assert_nil @hc_poll.active_question
  end
end
