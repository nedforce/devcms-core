require File.dirname(__FILE__) + '/../test_helper'

class PollQuestionsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  def test_should_get_show
    q = poll_questions(:hc_question_1)
    get :show, :id => q.id
    assert_response :success
    assert_equal q, assigns(:poll_question)
  end

  def test_should_show_results_if_inactive
    q = poll_questions(:hc_question_1)
    q.update_attribute(:active, false)
    get :show, :id => q.id
    assert_response :success
    assert_template 'results'
  end

  def test_should_get_results
    q = poll_questions(:hc_question_1)
    get :results, :id => q.id
    assert_response :success
    assert_equal q, assigns(:poll_question)
  end

  def test_should_get_results_with_ajax
    q = poll_questions(:hc_question_1)
    xhr :get, :results, :id => q.id
    assert_response :success
    #assert_select_rjs "sb_poll_content_#{q.poll.id}"
  end

  def test_should_vote
    q = poll_questions(:hc_question_1)
    po = q.poll_options.first
    
    assert_difference 'q.number_of_votes', 1 do
      assert_difference 'po.reload.number_of_votes', 1 do
        put :vote, :id => q.id, :poll_option_id => po.id
        assert_redirected_to results_poll_question_url(q)
        assert flash.has_key?(:notice)
      end
    end
  end

  def test_should_vote_with_ajax
    q = poll_questions(:hc_question_1)
    po = q.poll_options.first

    assert_difference 'q.number_of_votes', 1 do
      assert_difference 'po.reload.number_of_votes', 1 do
        xhr :put, :vote, :id => q.id, :poll_option_id => po.id
        assert_response :success
      end
    end
  end

  def test_should_vote_with_user_for_secured_poll
    login_as :arthur
    
    q = poll_questions(:hc_question_1)
    po = q.poll_options.first
    q.poll.update_attribute :requires_login, true

    assert_difference 'q.number_of_votes', 1 do
      assert_difference 'po.reload.number_of_votes', 1 do
        assert_difference 'q.user_votes.count', 1 do
          put :vote, :id => q.id, :poll_option_id => po.id
          assert q.has_vote_from?(users(:arthur))
          assert_response :redirect
        end
      end
    end
  end
  
  def test_should_require_user_for_secured_poll
    
    q = poll_questions(:hc_question_1)
    po = q.poll_options.first
    q.poll.update_attribute :requires_login, true

    assert_no_difference 'q.number_of_votes' do
      assert_no_difference 'po.reload.number_of_votes' do
        assert_no_difference 'q.user_votes.count' do
          put :vote, :id => q.id, :poll_option_id => po.id
          assert_redirected_to results_poll_question_url(q)
          assert flash.has_key?(:warning)
        end
      end
    end
  end

  def test_should_not_vote_for_inactive_question
    q = poll_questions(:hc_question_2)
    assert_no_difference 'q.number_of_votes' do
      put :vote, :id => q.id, :poll_option_id => q.poll_options.first.id
      assert_redirected_to results_poll_question_url(q)
      assert flash.has_key?(:warning)
    end
  end

  def test_should_not_allow_second_vote
    q = poll_questions(:hc_question_1)

    # create cookie
    @request.cookies["voted_for_#{q.id}"] = '1'

    # Second vote
    assert_no_difference 'q.number_of_votes' do
      put :vote, :id => q.id, :poll_option_id => q.poll_options.last.id
      assert_redirected_to results_poll_question_url(q)
      assert flash.has_key?(:warning) # not okay
    end
  end

end

