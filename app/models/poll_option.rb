# A +PollOption+ is a class that represents an option or an answer to a
# +PollQuestion+'s question or statement.
#
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
# * Requires +text+ to be unique within the scope of its +PollQuestion+'s
#   options.
#
class PollOption < ActiveRecord::Base
  # A +PollOption+ belongs to a +PollQuestion+.
  belongs_to :poll_question

  # See the preconditions overview for an explanation of these validations.
  # Don't +validate :poll_question, presence: true+ because PollQuestion calls
  # validates_associated, so that won't work.
  validates :text, presence: true, length: { maximum: 255 }, uniqueness: { scope: :poll_question_id }

  def vote!
    PollOption.increment_counter :number_of_votes, id if poll_question.active?
  end

  # Returns the percentage of votes casted for this option relative to all votes
  # for this option's question.  Returns 0 if there are no votes, regardless of
  # its question's total number of votes.
  def percentage_of_votes
    if total_votes > 0
      100 * (number_of_votes.to_f / total_votes.to_f)
    else
      0
    end
  end

  def total_votes
    @total_votes ||= poll_question.number_of_votes
  end
end
