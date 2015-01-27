require File.expand_path('../../test_helper.rb', __FILE__)

class PollQuestionTest < ActiveSupport::TestCase

  def test_should_create_poll_question
    assert_difference 'PollQuestion.count', 1 do
      pq = create_poll_question
      assert !pq.new_record?
    end
  end

  def test_should_create_poll_question_and_associated_poll_options
    assert_difference 'PollQuestion.count', 1 do
      assert_difference 'PollOption.count', 2 do
        pq = create_poll_question :new_poll_option_attributes => [ { :text => 'Option 1' }, { :text => 'Option 2' } ]
        assert !pq.new_record?
        assert_equal 2, pq.poll_options.count
      end
    end
  end

  test 'should require valid question' do
    assert_no_difference 'PollQuestion.count' do
      pq1 = create_poll_question question: nil
      assert !pq1.valid?
      assert pq1.errors[:question].any?

      pq2 = create_poll_question question: '  '
      assert !pq2.valid?
      assert pq2.errors[:question].any?
    end
  end

  test 'should not invalidate valid poll options when poll question is invalid on create' do
    assert_no_difference 'PollQuestion.count' do
      assert_no_difference 'PollOption.count' do
        pq = create_poll_question question: ' ', new_poll_option_attributes: [{ text: 'Option 1' }, { text: 'Option 2' }]
        assert !pq.valid?
        assert pq.errors[:question].any?

        pq.poll_options.each do |poll_option|
          assert poll_option.valid?
        end
      end
    end
  end

  test 'active should default to false' do
    pq = create_poll_question(active: nil)
    assert !pq.new_record?
    assert !pq.reload.active?
  end

  def test_should_not_allow_multiple_active_questions_for_single_poll_after_create
    2.times do |i|
      create_poll_question :question => 'Vraag ' + (i + 1).to_s
    end
    assert_equal 1, polls(:economy_poll).poll_questions.count(:conditions => { :active => true })
  end

  def test_should_not_allow_multiple_active_questions_for_single_poll_after_update
    poll_questions(:hc_question_1).send(:update_attributes, :active => true)
    poll_questions(:hc_question_2).send(:update_attributes, :active => true)
    assert_equal 1, polls(:healthcare_poll).poll_questions.count(:conditions => { :active => true })
  end

  def test_should_allow_one_active_question_per_poll
    poll_questions(:hc_question_1).send(:update_attributes, :active => true)
    poll_questions(:eco_question_1).send(:update_attributes, :active => true)
    poll_questions(:hc_question_2).send(:update_attributes, :active => true)

    assert_equal 2, PollQuestion.count(:conditions => { :active => true })
  end

  def test_should_return_correct_content_title
    long_question = "This is a very long question for a regular poll, I wonder if it'll fit into the tree view?"
    poll_questions(:hc_question_2).question = long_question
    ct = poll_questions(:hc_question_2).content_title
    assert ct.size < long_question.size
    assert_match(/\AThis.+(\.){3}.+view\?\z/, ct)
  end

  def test_should_destroy_question
    assert poll_questions(:hc_question_2).destroy
  end

  def test_should_return_total_nr_of_votes
    pq = poll_questions(:hc_question_1)
    vote_cnt = cast_loads_of_votes_for(pq)
    assert_equal vote_cnt, pq.number_of_votes
  end

  def test_new_poll_option_attributes_should_add_new_poll_options_after_save
    pq = poll_questions(:hc_question_1)

    assert_difference('pq.poll_options.count', 2) do
      pq.new_poll_option_attributes = [ { :text => 'Option 1' }, { :text => 'Option 2' } ]
      assert pq.save
    end
  end

  def test_new_poll_option_attributes_should_not_add_new_poll_options_after_save_if_a_poll_option_is_invalid
    pq = poll_questions(:hc_question_1)

    assert_no_difference('pq.poll_options.count') do
      pq.new_poll_option_attributes = [ { :text => 'Option 1' }, { :text => nil } ]
      assert !pq.save
    end
  end

  def test_new_poll_option_attributes_should_not_add_new_poll_options_after_save_if_argument_is_nil
    pq = poll_questions(:hc_question_1)

    assert_no_difference('pq.poll_options.count') do
      pq.new_poll_option_attributes = nil
      assert pq.save
    end
  end

  def test_existing_poll_option_attributes_should_update_existing_poll_options_after_save
    pq = poll_questions(:hc_question_1)
    poll_options = pq.poll_options
    existing_poll_option_attributes = {}

    poll_options.each do |poll_option|
      existing_poll_option_attributes.update(poll_option.id.to_s => { :text => 'Updated text' })
    end

    pq.existing_poll_option_attributes = existing_poll_option_attributes
    assert pq.save

    poll_options.each do |poll_option|
      assert_equal 'Updated text', poll_option.reload.text
    end
  end

  def test_existing_poll_option_attributes_should_not_update_existing_poll_options_after_save_if_a_poll_option_is_invalid
    pq = poll_questions(:hc_question_1)
    poll_options = pq.poll_options
    old_poll_option_texts = {}
    existing_poll_option_attributes = {}

    poll_options.each do |poll_option|
      poll_option_id = poll_option.id.to_s
      old_poll_option_texts.update(poll_option_id => poll_option.text)
      existing_poll_option_attributes.update(poll_option_id => { :text => nil })
    end

    pq.existing_poll_option_attributes = existing_poll_option_attributes
    assert !pq.save

    poll_options.each do |poll_option|
      assert_equal old_poll_option_texts[poll_option.id.to_s], poll_option.reload.text
    end
  end

  def test_existing_poll_option_attributes_should_not_update_existing_poll_options_after_save_if_argument_is_nil
    pq = poll_questions(:hc_question_1)
    poll_options = pq.poll_options
    old_poll_option_texts = {}

    poll_options.each do |poll_option|
      poll_option_id = poll_option.id.to_s
      old_poll_option_texts.update(poll_option_id => poll_option.text)
    end

    pq.existing_poll_option_attributes = nil
    assert pq.save

    poll_options.each do |poll_option|
      assert_equal old_poll_option_texts[poll_option.id.to_s], poll_option.reload.text
    end
  end

  def test_human_name_does_not_return_nil
    assert_not_nil PollQuestion.human_name 
  end

  def test_should_not_return_poll_question_children_for_menu
    assert poll_questions(:hc_question_1).node.children.accessible.shown_in_menu.empty?
  end

  def test_should_have_a_title
    assert_not_nil poll_questions(:hc_question_1).title
    assert_equal poll_questions(:hc_question_1).content_title, poll_questions(:hc_question_1).title
  end

  def test_should_register_votes
    pq = poll_questions(:hc_question_1)
    poll_option = pq.poll_options.first

    assert_difference('poll_option.reload.number_of_votes', 1) do
      pq.vote(poll_option)
    end
  end

  def test_should_require_user_for_poll
    pq = poll_questions(:hc_question_1)
    pq.poll.update_attribute :requires_login, true
    assert pq.poll.reload.requires_login?

    poll_option = pq.poll_options.first
    assert_no_difference('poll_option.reload.number_of_votes') do
      assert_no_difference('pq.user_votes.count') do
        pq.vote(poll_option)
      end
    end
  end

  def test_should_register_votes_for_user
    pq = poll_questions(:hc_question_1)
    pq.poll.update_attribute :requires_login, true

    poll_option = pq.poll_options.first
    assert_difference('poll_option.reload.number_of_votes', 1) do
      assert_difference('pq.user_votes.count', 1) do
        pq.vote(poll_option, users(:arthur))
        assert pq.has_vote_from?(users(:arthur))
      end
    end
  end

  def test_should_register_only_one_vote_per_user
    pq = poll_questions(:hc_question_1)
    pq.poll.update_attribute :requires_login, true
    poll_option = pq.poll_options.first

    assert_difference('poll_option.reload.number_of_votes', 1) do
      assert_difference('pq.user_votes.count', 1) do
        pq.vote(poll_option, users(:arthur))
      end
    end
    assert_no_difference('poll_option.reload.number_of_votes') do
      assert_no_difference('pq.user_votes.count') do
        pq.vote(poll_option, users(:arthur))
      end
    end
  end

protected

  def create_poll_question(options = {})
    PollQuestion.create({ :parent => nodes(:economie_poll_node), :active => true, :question => 'Gaat u op vakantie?' }.merge(options))    
  end

  def cast_loads_of_votes_for(pq)
    PollOption.update_all('number_of_votes = 0')
    vote_cnt = 0

    pq.poll_options.each do |o|
      10.times do
        o.vote!
        vote_cnt += 1
      end
    end
    vote_cnt
  end
end
