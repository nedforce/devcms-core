class LoginAttempt < ActiveRecord::Base

  validates_presence_of :ip

  # Checks if the given +ip+ is blocked. If so, returns
  # the date of unblock. If not, returns +nil+.
  def self.is_ip_blocked?(ip)
    last_ten_attempts = LoginAttempt.order('created_at desc').where(:ip => ip).limit(10)

    if last_ten_attempts.map(&:success).count(false) == 10
      return last_ten_attempts.first.created_at.tomorrow
    else
      nil
    end
  end

  def self.last_attempt_was_not_ten_seconds_ago(ip)
    last_attempt = LoginAttempt.last(:conditions => { :ip => ip })
    (last_attempt.created_at > (Time.now - 10.seconds)) if last_attempt
  end
end
