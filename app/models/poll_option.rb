# A +PollOption+ is a class that represents an option or an answer to a
# +PollQuestion+'s question or statement.

# A +PollOption+ has many +PollVote+ objects and belongs to a +PollQuestion+.
#
# *Specification*
# 
# Attributes
# 
# * +text+ - The option/answer as a string.
# * +number_of_votes+ - The number of votes this poll option received.
# * +poll_question+ - The poll question this poll option belongs to.
#
# Preconditions
#
# * Requires the presence of a +PollQuestion+ as its owner.
# * Requires the presence of +text+.
# 
# * Requires +text+ to be a string of at least 1 and max 255 characters.
# * Requires +text+ to be unique within the scope of its +PollQuestion+'s options.
#
class PollOption < ActiveRecord::Base

  # A +PollOption+ belongs to a +PollQuestion+.
  belongs_to :poll_question

  # See the preconditions overview for an explanation of these validations.
  # Don't validate_presence_of :poll_question because PollQuestion calls
  # validates_associated, so that won't work.
  validates_presence_of   :text
  validates_length_of     :text, :in => 1..255  
  validates_uniqueness_of :text, :scope => :poll_question_id

  # Increases the vote count for this option in a single SQL execution.
  def vote!
    connection.update("UPDATE poll_options SET number_of_votes = number_of_votes + 1 WHERE id = #{self.id}") if self.poll_question.active?
    reload # Make sure the new value is read from the db.
  end

  # Returns the percentage of votes casted for this option relative to all votes for
  # this option's question.
  #
  # Returns 0 if there are no votes, regardless of its question's total number of votes.
  def percentage_of_votes
    total = self.poll_question.number_of_votes
    total == 0 ? 0 : 100 * (self.number_of_votes.to_f / total.to_f)
  end
end
