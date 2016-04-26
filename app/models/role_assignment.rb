class RoleAssignment < ActiveRecord::Base
  belongs_to :user
  belongs_to :node

  PRIVILEGED_ROLES = %w(admin editor final_editor)
  READONLY_ROLES = %w(read_access indexer)

  ALL_ROLES = PRIVILEGED_ROLES + READONLY_ROLES

  ROLES = {
    admin:        I18n.t('roles.admin'),
    editor:       I18n.t('roles.editor'),
    final_editor: I18n.t('roles.final_editor'),
    read_access:  I18n.t('roles.private'),
    indexer:      I18n.t('roles.indexer')
  }

  ALLOWED_TYPES = %w(
    Calendar Feed NewsArchive NewsletterArchive Page PermitArchive Poll
    ProductCatalogue ResearchArchive Section Site Weblog WeblogArchive
  )

  validates :user, presence: true
  validates :node, presence: true
  validates :name, presence: true, inclusion: { in: RoleAssignment::ROLES.keys.map(&:to_s) }
  validates :user_id, numericality: true
  validates :node_id, numericality: true
  validates_uniqueness_of :node_id, scope: :user_id
  validate :secure_user_for_write_access, if: :is_privileged?
  validate :content_class
  validate :root_if_admin
  validate :no_inherited_roles

  def is_privileged?
    PRIVILEGED_ROLES.include?(name)
  end

  protected

  def content_class
    if node && !ALLOWED_TYPES.include?(node.content_type)
      errors.add(:node, :invalid_node_type)
    end
  end

  def root_if_admin
    if node && name == 'admin' && !node.root?
      errors.add(:node, :admin_requires_root)
    end
  end

  # Validator method to check whether the +User+ this +RoleAssignment+ is being
  # created for, has no inherited rights from its ancestor +Nodes+.
  def no_inherited_roles
    errors.add(:base, :inherited_roles) if user && user.has_role_on?(user.role_assignments.map(&:name), node)
  end

  def secure_user_for_write_access
    unless user.present? && user.is_privileged?
      errors.add(:user, :role_requires_priviliged_user)
    end
  end
end
