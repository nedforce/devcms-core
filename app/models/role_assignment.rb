class RoleAssignment < ActiveRecord::Base
  belongs_to :user
  belongs_to :node

  ALL_ROLES = %w(
    admin editor final_editor read_access indexer
  )

  ROLES = {
    :admin        => I18n.t('roles.admin'),
    :editor       => I18n.t('roles.editor'),
    :final_editor => I18n.t('roles.final_editor'),
    :read_access  => I18n.t('roles.private'),
    :indexer      => I18n.t('roles.indexer')
  }

  ALLOWED_TYPES = %w(
    Calendar Feed NewsArchive NewsletterArchive Page PermitArchive Poll ProductCatalogue ResearchArchive Section Site Weblog WeblogArchive
  )

  validates_presence_of     :user, :node, :name
  validates_numericality_of :user_id, :node_id
  validates_uniqueness_of   :node_id, :scope => :user_id
  validates_inclusion_of    :name,    :in => RoleAssignment::ROLES.keys.map(&:to_s)
  validate :content_class
  validate :root_if_admin
  validate :no_inherited_roles

  protected

  def content_class
    # TODO: Refactor "unless if"
    unless ALLOWED_TYPES.include?(self.node.content_type)
      errors.add(:node, :invalid_node_type)
    end if self.node
  end

  def root_if_admin
    # TODO: Refactor "unless != || if"
    errors.add(:node, :admin_requires_root) unless self.name != "admin" || self.node.root? if self.node
  end

  # Validator method to check whether the +User+ this +RoleAssignment+ is being created
  # for has no inherited rights from its ancestor +Nodes+.
  def no_inherited_roles
    errors.add_to_base(:inherited_roles) if user && user.has_role_on?(user.role_assignments.map(&:name), node)
  end
end

# == Schema Information
#
# Table name: role_assignments
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  node_id    :integer
#  name       :string(255)     not null
#  created_at :datetime
#  updated_at :datetime
#
