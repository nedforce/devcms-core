require File.expand_path('../../test_helper.rb', __FILE__)

class PollQuestionsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  test 'should get show' do
    q = poll_questions(:hc_question_1)
    get :show, id: q.id
    assert_response :success
    assert_equal q, assigns(:poll_question)
  end

  test 'should get show results if inactive' do
    q = poll_questions(:hc_question_1)
    q.update_attribute(:active, false)
    get :show, id: q.id
    assert_response :success
    assert_template 'results'
  end

  test 'should get results' do
    q = poll_questions(:hc_question_1)
    get :results, id: q.id
    assert_response :success
    assert_equal q, assigns(:poll_question)
  end

  test 'should get results with ajax' do
    q = poll_questions(:hc_question_1)
    xhr :get, :results, id: q.id
    assert_response :success
  end

  test 'should vote' do
    q = poll_questions(:hc_question_1)
    po = q.poll_options.first

    assert_difference 'q.number_of_votes', 1 do
      assert_difference 'po.reload.number_of_votes', 1 do
        put :vote, id: q.id, poll_option_id: po.id
        assert_redirected_to results_poll_question_url(q)
        assert flash.key?(:notice)
      end
    end
  end

  test 'should vote with ajax' do
    q = poll_questions(:hc_question_1)
    po = q.poll_options.first

    assert_difference 'q.number_of_votes', 1 do
      assert_difference 'po.reload.number_of_votes', 1 do
        xhr :put, :vote, id: q.id, poll_option_id: po.id
        assert_response :success
      end
    end
  end

  test 'should vote with user for secured poll' do
    login_as :arthur

    q = poll_questions(:hc_question_1)
    po = q.poll_options.first
    q.poll.update_attribute :requires_login, true

    assert_difference 'q.number_of_votes', 1 do
      assert_difference 'po.reload.number_of_votes', 1 do
        assert_difference 'q.user_votes.count', 1 do
          put :vote, id: q.id, poll_option_id: po.id
          assert q.has_vote_from?(users(:arthur))
          assert_response :redirect
        end
      end
    end
  end

  test 'should require user for secured poll' do
    q = poll_questions(:hc_question_1)
    po = q.poll_options.first
    q.poll.update_attribute :requires_login, true

    assert_no_difference 'q.number_of_votes' do
      assert_no_difference 'po.reload.number_of_votes' do
        assert_no_difference 'q.user_votes.count' do
          put :vote, id: q.id, poll_option_id: po.id
          assert_redirected_to results_poll_question_url(q)
          assert flash.key?(:warning)
        end
      end
    end
  end

  test 'should not vote for inactive question' do
    q = poll_questions(:hc_question_2)

    assert_no_difference 'q.number_of_votes' do
      put :vote, id: q.id, poll_option_id: q.poll_options.first.id
      assert_redirected_to results_poll_question_url(q)
      assert flash.key?(:warning)
    end
  end

  test 'should not allow second vote' do
    q = poll_questions(:hc_question_1)

    # Create cookie
    @request.cookies["voted_for_#{q.id}"] = '1'

    # Second vote
    assert_no_difference 'q.number_of_votes' do
      put :vote, id: q.id, poll_option_id: q.poll_options.last.id
      assert_redirected_to results_poll_question_url(q)
      assert flash.key?(:warning) # Not okay
    end
  end
end
