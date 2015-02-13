class LoginAttempt < ActiveRecord::Base
  validates :ip, presence: true

  scope :by_created_at, lambda { order('created_at DESC') }
  scope :for_ip,        lambda { |ip| where(ip: ip) }
  scope :since,         lambda { |time| where(created_at: time..Time.now) }
  scope :failed,        lambda { where(success: [false, nil]) }

  # Checks if the given +ip+ is blocked.
  # If so, returns the date of unblock. If not, returns +nil+.
  def self.is_ip_blocked?(ip)
    last_ten_attempts = LoginAttempt.by_created_at.for_ip(ip).since(Time.now.yesterday).limit(10)

    if last_ten_attempts.map(&:success).count(false) == 10
      last_ten_attempts.first.created_at.tomorrow
    end
  end

  def self.last_attempt_was_not_ten_seconds_ago(ip)
    LoginAttempt.failed.for_ip(ip).since(10.seconds.ago).exists?
  end
end
