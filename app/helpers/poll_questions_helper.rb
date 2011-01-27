module PollQuestionsHelper

  def poll_enabled?(poll)
     !poll.requires_login? || logged_in?
  end

  def already_voted_for?(question)
    if question.poll.requires_login?
      question.has_vote_from?(current_user)
    else
      vote_cookie_for?(question)
    end
  end

  # Check for a cookie that a given poll +question+ was voted for.
  def vote_cookie_for?(question)
    cookies["voted_for_#{question.id}"] == '1'
  end 

  # Set a cookie with expiration date that a given poll +question+ was voted for.
  def bake_vote_cookie_for(question)
    cookies["voted_for_#{question.id}"] = {
      :value   => '1',
      :expires => 1.year.from_now # Expire not anytime soon.
    }
  end
end
