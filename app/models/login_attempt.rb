class LoginAttempt < ActiveRecord::Base
  
  validates_presence_of :ip
  
  named_scope :failed, :conditions => { :success => false }
  
  # Checks if the given +ip+ is blocked. If so, returns
  # the date of unblock. If not, returns +nil+.
  def self.is_ip_blocked?(ip)
    attempts = LoginAttempt.failed.all(:conditions => { :ip => ip, :created_at => Time.now.yesterday..Time.now })
    return attempts.first.created_at.tomorrow if attempts.count >= 10
    nil
  end
  
  def self.last_attempt_was_not_ten_seconds_ago(ip)
    last_attempt = LoginAttempt.last(:conditions => {:ip => ip})
    (last_attempt.created_at > (Time.now - 10.seconds)) if last_attempt
  end
  
end
