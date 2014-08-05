# A +PollQuestion+ is a content node that represents a question/statement with
# several options which users can vote for.
#
# It has specified +acts_as_content_node+ from Acts::ContentNode::ClassMethods.
#
# A +PollQuestion+ has many +PollOption+ objects and belongs to a +Poll+.
#
# *Specification*
#
# Attributes
#
# * +question+ - The question/statement as a string.
# * +active+ - A boolean indicating whether the question is active or not.
# * +poll+ - The poll this poll question belongs to.
#
# Preconditions
#
# * Requires the presence of +question+.
# * Requires +question+ to be a string of at least 2 and max 255 characters.
# * Requires +active+ to have a boolean value if present. Defaults to +false+ if not present.
#
# Child/parent type constraints
#
# * A +PollQuestion+ can only be inserted into nodes of the +Poll+ type.
#
class PollQuestion < ActiveRecord::Base
  # Adds content node functionality to poll questions.
  acts_as_content_node({
    show_in_menu: false,
    copyable:     false
  })

  # A +PollQuestion+ belongs to a +Poll+.
  has_parent :poll

  # A +PollQuestion+ has many +PollOption+ objects.
  has_many :poll_options, dependent: :destroy, order: 'created_at'

  has_many :user_votes, class_name: 'UserPollQuestionVote', dependent: :destroy

  # See the preconditions overview for an explanation of these validations.
  validates_presence_of  :poll, :question
  validates_length_of    :question, in: 2..255,        allow_blank: true
  validates_inclusion_of :active,   in: [true, false], allow_nil: true

  # Ensures that all the associated +PollOption+ objects are validated when this
  # +PollQuestion+ is validated.
  validates_associated :poll_options

  # Ensure there is always only one active +PollQuestion+.
  before_save :ensure_unique_active_question

  # Ensure the updated +PollOption+ objects are saved.
  after_update :save_poll_options

  after_paranoid_delete :remove_associated_content

  # Virtual attribute to allow the creation of new +PollOption+ objects from an attribute hash.
  def new_poll_option_attributes=(option_attributes)
    option_attributes.each do |attributes|
      self.poll_options.build(attributes)
    end unless option_attributes.nil?
  end

  # Virtual attribute to allow the change and destruction of associated +PollOption+ objects.
  def existing_poll_option_attributes=(option_attributes)
    self.poll_options.reject(&:new_record?).each do |poll_option|
      attributes = option_attributes[poll_option.id.to_s]

      if attributes # Attributes are present so we need to update.
        poll_option.attributes = attributes
      else # No attributes are present so we need to delete.
        self.poll_options.delete(poll_option)
      end
    end unless option_attributes.nil?
  end

  # Returns the question as being this content node's title
  # and shrinks it if the question is too long.
  def content_title
    question.size > 24 ? question[0..10] + '...' + question[-10..-1] : question
  end

  # Returns the total number of votes for all of this question's options.
  def number_of_votes
    self.poll_options.sum(:number_of_votes)
  end

  # TODO: Documentation
  def tree_text(node)
    txt = content_title
    txt += ' (Actief)' if self.active?
    txt
  end

  # Returns the question as the token for indexing.
  def content_tokens
    question
  end

  # Aliases +content_title+ as +title+.
  def title
    content_title
  end

  def title_changed?
    self.question_changed?
  end

  def has_vote_from?(user)
    user.present? && user_votes.exists?(user_id: user.id)
  end

  # Record a vote on an option
  # For polls that require a logged in user, user has to be given or the vote is ignored
  # Checks for existing votes aswell
  def vote(option, user = nil)
    if poll.requires_login?
      if user.present? && !has_vote_from?(user)
        PollQuestion.transaction do
          registration = user_votes.create(user: user)
          poll_options.find(option).vote! if registration
        end
      end
    else
      poll_options.find(option).vote!
    end
  end

  def last_updated_at
    [self.updated_at, self.poll_options.maximum(:updated_at)].compact.max
  end

protected

  # Before save callback.
  #
  # Sets all questions for this question's poll to be inactive if this question will
  # be activated on save to ensure only one active question per poll.
  def ensure_unique_active_question
    if self.active_changed? && self.active
      self.poll.poll_questions.each { |pq| pq.update_attribute(:active, false) }
    end
  end

  # Ensures the updated +PollOption+ objects are saved.
  def save_poll_options
    self.poll_options.each do |poll_option|
      poll_option.save(validate: false)
    end
  end

  def remove_associated_content
    self.poll_options.destroy_all
    self.user_votes.destroy_all
  end
end
