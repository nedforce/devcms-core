# This model is used to represent a user of the application who has/can have
# more than read access. Privileged users have more strict security policies.
class PrivilegedUser < User
  has_many :role_assignments, dependent: :destroy, foreign_key: :user_id

  # A +User+ has many nodes it has a role assigned on
  has_many :assigned_nodes, through: :role_assignments, source: :node

  scope :admins,        -> { includes(:role_assignments).where('role_assignments.name' => 'admin') }
  scope :final_editors, -> { includes(:role_assignments).where('role_assignments.name' => 'final_editor') }
  scope :editors,       -> { includes(:role_assignments).where('role_assignments.name' => 'editor') }

  def demote!
    update_column :type, 'User'
  end
end
