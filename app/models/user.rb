# This model is used to represent a user of the application. As such, it
# contains personal information, such as the email address of the user in
# question. Furthermore, this model contains the login credentials of the user,
# as well as functionality to reset and/or set a password. Finally, it is
# possible to enable/disable 'cookie remember' functionality here.
#
# <b>Credentials storage</b>
#
# The user's login is stored as plaintext in the database. The password, for
# security reasons, is encrypted using an SHA-256 hash algorithm with a
# dynamically generated pseudorandom salt. The resulting hash is stored in
# +password_hash+, the accompanying salt is stored in +password_salt+.
#
# <b>Cookie remember functionality</b>
#
# This model contains various methods to enable the application to remember
# users between browser closes. This allows users to skip authentication the
# next time they user the application. To achieve this, cookies are employed.
# The methods in question are used to set and/or read specific values from these
# cookies.
#
# *Specification*
#
# Attributes
#
# * +login+ - The user's login to the application.
# * +email_address+ - The user's email address.
# * +password+ - Virtual attribute that holds the user's password when it's edited/set.
# * +password_confirmation+ - Virtual attribute that holds the confirmation of the user's password when it's edited/set (created by the +validates_confirmation_of+ macro).
# * +password_hash+ - The SHA-256 hash of the user's password.
# * +password_salt+ - The salt used to calculate the password hash.
# * +verified+ - Set the true if the user is verified, false otherwise.
# * +verficiation_code+ - Code used for verifying the user, if the user is not verified yet.
# * +first_name+ - The first name of the user.
# * +surname+ - The last name of the user.
# * +sex+ - The sex of the user.
#
# Preconditions
#
# * Requires the presence of +login+.
# * Requires the presence of +email_address+.
# * Requires the presence of +password+, if no password is set yet.
# * Requires the presence of +password_confirmation+, if no password is set yet.
# * Requires +login+ to contain only alphanumerical characters or - and _.
# * Requires uniqueness of +login+.
# * Requires uniqueness of +email_address+.
# * Requires +password_confirmation+ to confirm (i.e., be equal to) +password+, if no password is set yet
# * Requires that +login+ is not a reserved login.
# * Requires +sex+ to be either male ('m') or female ('f')
#
require 'digest'
require 'digest/sha2'

class User < ActiveRecord::Base
  include DevcmsCore::TokenGeneration

  SEXES = {
    'm' => :male,
    'f' => :female
  }

  scope :exclusive, ->{ where('users.type IS NULL OR users.type = ?', 'User') }

  # Virtual attribute to hold the unencrypted password
  attr_accessor :password

  # Set to force users to supply a password
  attr_accessor :require_password

  # A +User+ can have multiple nodes which he has edited
  has_many :nodes, foreign_key: :editor_by

  # A +User+ can have multiple comments
  has_many :comments, dependent: :nullify

  # A +User+ can have multiple weblogs, which he owns.
  has_many :weblogs, dependent: :destroy

  # A +User+ has many +RoleAssignment+ objects (i.e., roles).
  has_many :role_assignments, ->{ where(name: %w(read_access indexer)) }, dependent: :destroy

  has_many :user_poll_question_votes, dependent: :destroy

  # A +User+ has and belongs to many +NewsletterArchive+ objects (i.e., subscriptions to newsletters).
  #has_and_belongs_to_many :newsletter_archives
  has_many :newsletter_archives_users, dependent: :destroy
  has_many :newsletter_archives, through: :newsletter_archives_users

  has_many :newsletter_edition_queues

  # A +User+ has and belongs to many +Interest+ objects (i.e., general news or art).
  has_and_belongs_to_many :interests

  # A +User+ can have started many forum threads.
  has_many :forum_threads,   dependent: :destroy

  # A +User+ can have created many forum posts.
  has_many :forum_posts,     dependent: :destroy

  has_many :versions,        foreign_key: :editor_id, dependent: :destroy

  has_many :event_registrations, dependent: :destroy

  has_many :created_nodes, foreign_key: :created_by_id, class_name: 'Node', dependent: :nullify
  has_many :updated_nodes, foreign_key: :updated_by_id, class_name: 'Node', dependent: :nullify

  # See the preconditions overview for an explanation of these validations.
  validates_presence_of     :password,              if: :password_required?
  validates_presence_of     :password_confirmation, if: :password_required?
  validates_length_of       :password, in: 2..255,  if: :password_required?, allow_blank: true
  validates_confirmation_of :password,              if: :password_required?

  validates :login, presence: true, uniqueness: { case_sensitive: false }
  validates_length_of :login, in: 2..255,                on: :create, allow_blank: true
  validates_format_of :login, with: /\A[a-z0-9_\-]+\z/i, on: :create, unless: Proc.new { |user| user.login.blank? }

  validates :email_address, presence: true, email: { allow_blank: true }

  # To make sure editing still checks uniqueness
  validates_uniqueness_of   :email_address, case_sensitive: false, if: :persisted?

  validates :verification_code, presence: true

  validates :sex, inclusion: { in: User::SEXES.keys, allow_blank: true }

  validate :should_not_allow_reserved_login

  validate :privileged_users_password_should_be_strong, unless: Proc.new { Rails.env.development? }
  validate :password_should_be_different_from_original, if: ->{ password_required? && should_renew_password? }

  # Make sure the user's password (stored in the virtual attribute +password+)
  # is stored as a hash after the user is created/updatedRoleAssignment.
  before_save :encrypt_password
  before_save { self.renewed_password_at = Time.now if password.present? }
  before_save { generate_token(:auth_token) if auth_token.nil? }

  # Make sure the email is unique and no error is shown
  before_create :validate_uniqueness_of_email

  # Make sure a verification code is set when a user first registers.
  before_validation :set_verification_code, on: :create

  after_create :send_verification_email_or_verify

  # Login can not be changed after registration.
  attr_readonly :login

  # An array of field names that are considered to be information-sensitive.
  SECRETS = %w( password_hash password_salt auth_token verification_code password_reset_token ).freeze

  # The original ActiveRecord::Base.to_xml that also includes information-sensitive fields.
  alias_method :to_xml_with_secrets,  :to_xml
  # The original ActiveRecord::Base.to_json that also includes information-sensitive fields.
  alias_method :to_json_with_secrets, :to_json

  # This overridden to_xml method returns an XML representation without information-sensitive fields.
  def to_xml(options = {})
    to_xml_with_secrets(options.merge({ except: SECRETS }))
  end

  # This overridden to_json method returns a JSON representation without information-sensitive fields.
  def to_json(options = {})
    to_json_with_secrets(options.merge({ except: SECRETS }))
  end

  # Authenticates a user by their login and unencrypted password. Returns the user if successfully authenticated, elsen nil.
  def self.authenticate(login, password)
    return unless login.present?

    if user = User.where('LOWER(login) = LOWER(?)', login).first

      if user.authenticated?(password)
        user.update_attribute :failed_logins, 0
        user
      else
        # TODO: move this to a separate +block+ method, so we can actually reuse it;
        #       also make the number of failed logins a +Settler+ setting.
        if user.is_privileged? && user.failed_logins == 9 # 10th failed attempt on a privileged user...
          user.blocked = true
          user.failed_logins = 10
          user.save!
        else
          user.increment! :failed_logins
        end

        nil
      end

    end
  end

  # Encrypts the given password with the given salt, using the SHA-256 hash algorithm.
  def self.encrypt(password, salt)
    Digest::SHA256.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user's salt set in the +password_salt+ field.
  def encrypt(password)
    self.class.encrypt(password, password_salt)
  end

  # Checks whether the given password can be used to authenticate the user.
  def authenticated?(password)
    password_hash == encrypt(password)
  end

  def is_privileged?
    self.type.to_s == 'PrivilegedUser'
  end

  # Determins whether this user has a +RoleAssignment+ with (one of) the given name(s) for the given node or one of its ancestors.
  # If no node is given, the +Node.root+ is used.
  # Arguments
  #  +role+ A string with the name of the role. Any number of roles can be given here.
  #  +roles+ Instead of multiple strings, an array containing strings can be used too.
  #  +node+ The last argument may be the +Node+ to find the +RoleAssignments+ for.
  def has_role_on?(*args)
    node  = args.last.is_a?(Node)   ? args.pop   : Node.root
    roles = args.first.is_a?(Array) ? args.first : args
    self.role_assignments.where(node_id: node.path_ids, name: roles).exists?
  end

  # Checks whether a user has one of the given roles.
  # Arguments
  #  +roles+ one or more Strings containing role names.
  def has_role?(*args)
    roles = args.first.is_a?(Array) ? args.first : args
    self.role_assignments.where(name: roles).exists?
  end

  # Checks whether a user has whatever role on whatever node.
  def has_any_role?
    self.role_assignments.exists?
  end

  # Checks whether this user has a +RoleAssignment+ for the given node or one of its ancestors.
  # Faster than the other 'has_*_role* methods because of memoizing.
  # If no node is supplied, checks whether a user has whatever role on whatever node.
  def has_any_role?(node = nil)
    if node
      node = node.new_record? ? node.parent : node
      fetch_role_assignments.any? { |ra| node.self_and_ancestor_ids.include?(ra.node_id) }
    else
      fetch_role_assignments.any?
    end
  end

  # Returns the role the user has on a Node.
  def role_on(node)
    self.role_assignments.where(node_id: node.path_ids).first
  end

  # Gives the user a role for a specific Node.
  # Returns true on success, false if the role is invalid.
  def give_role_on(role_name, node)
    ra = self.role_assignments.create(node: node, name: role_name)
    return ra.persisted?
  end

  # Removes any role assigned to the given node.
  def remove_role_from(node)
    r = self.role_assignments.find_by_node_id(node.id)
    r.destroy unless r.nil?
  end

  # Returns true if this User has a subscription for the NewsLetterArchive specified by the +newsletter_archive+ argument, false otherwise.
  def has_subscription_for?(newsletter_archive)
    self.newsletter_archives.include?(newsletter_archive)
  end

  # Verifies this user if the given code is equal to the user's +verification_code+.
  def verify_with(code)
    return (code == self.verification_code) ? self.verify! : false
  end

  # Verifies the user, regardless of a verification code.
  def verify!
    self.update_attribute(:verified, true)
  end

  # Generates and returns a usable verification code of 10 hexadecimal characters.
  def self.generate_verification_code_for(user)
    i = rand(30)
    Digest::SHA1.hexdigest("#{user.login}-#{Time.now}")[i..(i+9)]
  end

  # Sets and saves a new verification code for this user.
  def reset_verification_code
    self.set_verification_code
    self.save!
  end

  # Sends an invitation email to the given email_address.
  # Returns +true+ if the email has been successfully sent, otherwise +false+.
  def self.send_invitation_email!(email_address)
    return false if email_address.blank?

    UserMailer.invitation_email(email_address, self.generate_invitation_code(email_address)).deliver_now

    true
  rescue
    false
  end

  # TODO: Documentation
  def send_verification_email_or_verify
    Settler[:user_verify] ? UserMailer.verification_email(self).deliver_now : self.verify!
  end

  # Verify a given +invitation_code+ based on the supplied +email_address+.
  #
  # Returns true if the +invitation_code+ is valid for the supplied +email_address+, false otherwise.
  def self.verify_invitation_code(email_address, invitation_code)
    return false if email_address.blank? || invitation_code.blank?

    self.generate_invitation_code(email_address) == invitation_code
  end

  # Generates a token for use with the password reset form
  # Returns the generated token
  def create_password_reset_token
    begin
      self.password_reset_token = Digest::SHA1.hexdigest("--#{Time.now}--#{self.object_id}--")
    end while User.where(password_reset_token: self.password_reset_token).exists? # must be unique
    self.password_reset_expiration = Time.now + 6.hours
    save!
  end

  # Returns first and surname (String).
  def full_name
    [first_name, surname].join(' ').strip
  end

  # Returns the name to use on the frontend.
  def screen_name
    full_name.present? ? full_name : login
  end

  # Aliases +login+ as +to_param+.
  def to_param
    login
  end

  def to_s
    full_name.present? ? "#{full_name} (#{login})" : login
  end

  def csv_row
    [email_address, (first_name if first_name.present?), (surname if surname.present?), sex]
  end

  def promote!
    update_column :type, 'PrivilegedUser'
  end

  def should_renew_password?
    DevcmsCore.config.enforce_password_renewal &&
    is_privileged? &&
    renewed_password_at.present? &&
    renewed_password_at < DevcmsCore.config.renew_password_after.ago
  end

  protected

  # Memoized reader for the role_assignments association
  def fetch_role_assignments
    @role_assignments ||= role_assignments.to_a
  end

  # Set a new verification_code for the user.
  def set_verification_code
    self.verification_code = User.generate_verification_code_for(self)
  end

  # Make sure the user's password (stored in the virtual attribute +password+)
  # is stored as a hash, along with the used salt.
  def encrypt_password
    return if password.blank?
    self.password_salt = [Array.new(6){ rand(256).chr }.join].pack("m").chomp if new_record?
    self.password_hash = encrypt(password)
  end

  def password_should_be_different_from_original
    return if password.blank?
    errors.add(:password, :password_equals_current_password) if authenticated?(password)
  end

  # Returns true if a password should be supplied, else false.
  def password_required?
    password_hash.blank? || password.present? || @require_password
  end

  # Prevents users from registering reserved logins.
  def should_not_allow_reserved_login
    # TODO: Move to global setting & generalize unit test
    errors.add(:login, :reserved_login) if login =~ Devcms.reserved_logins_regex
  end

  # Prevents information leakage, validates the email and returns false to prevent a save
  def validate_uniqueness_of_email
    user = User.where('UPPER(email_address) = UPPER(?)', email_address).first
    UserMailer.email_used_to_create_account(user).deliver_now if user

    !user
  end

  def privileged_users_password_should_be_strong
    return if password.blank?
    errors.add(:password, :password_not_strong_enough) if is_privileged? && User.password_entropy(password) < (Settler[:password_required_entropy] ? Settler[:password_required_entropy] : 66)
  end

  # Password entropy based on: http://blog.shay.co/password-entropy/
  def self.password_entropy(password)
    password.length == 0 ? 0 : password.length * Math.log(password_alphabet(password)) / Math.log(2)
  end

  # Determines the password alphabet size.
  def self.password_alphabet(password)
    alphabet = 0
    lower    = false
    upper    = false
    numbers  = false
    symbols1 = false
    symbols2 = false

    password.each_char do |c|
      if !lower && !c.match('[a-z]').nil?
        lower = true
        alphabet += 26
      elsif !upper && !c.match('[A-Z]').nil?
        upper = true
        alphabet += 26
      elsif !numbers && !c.match('[0-9]').nil?
        numbers = true
        alphabet += 10
      elsif !symbols1 && '!@#$%^&*()'.include?(c)
        symbols1 = true
        alphabet += 10
      elsif !symbols2 && '~`-_=+[]{}\\|;:\'",.<>?/'.include?(c)
        symbols2 = true
        alphabet += 22
      else
        alphabet += 1
      end
    end

    alphabet
  end

  # Returns an invitation code for a user, based on the user's +email_address+.
  def self.generate_invitation_code(email_address)
    Digest::SHA256.hexdigest(email_address)
  end
end
