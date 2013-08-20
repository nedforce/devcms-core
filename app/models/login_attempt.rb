class LoginAttempt < ActiveRecord::Base

  validates_presence_of :ip

  scope :by_created_at,   lambda { order('created_at DESC') }
  scope :for_ip,          lambda { |ip| where(:ip => ip) }
  scope :since_yesterday, lambda { where(:created_at => Time.now.yesterday..Time.now) }

  # Checks if the given +ip+ is blocked. If so, returns
  # the date of unblock. If not, returns +nil+.
  def self.is_ip_blocked?(ip)
    last_ten_attempts = LoginAttempt.by_created_at.for_ip(ip).since_yesterday.limit(10)

    if last_ten_attempts.map(&:success).count(false) == 10
      last_ten_attempts.first.created_at.tomorrow
    else
      nil
    end
  end

  def self.last_attempt_was_not_ten_seconds_ago(ip)
    last_attempt = LoginAttempt.for_ip(ip).last
    (last_attempt.created_at > (Time.now - 10.seconds)) if last_attempt
  end
end
