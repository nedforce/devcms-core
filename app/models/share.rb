class Share < ActiveRecord::Base
  # Some methods to create a tableless ActiveRecord model.
  def self.columns; @columns ||= []; end

  def self.column(name, sql_type = nil, default = nil, null = true)
    type = "ActiveRecord::Type::#{sql_type.to_s.camelize}".constantize.new
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, type, null)
  end

  column :node_id,            :integer
  column :from_email_address, :string
  column :from_name,          :string
  column :to_email_address,   :string
  column :to_name,            :string
  column :message,            :text

  belongs_to :node

  # See the preconditions overview for an explanation of these validations.
  validates_presence_of :from_email_address, :to_email_address, :from_name, :to_name, :node, :message

  validates :from_email_address, :to_email_address, email: { allow_blank: true }

  def subject
    node.content.title if node.present? && node.content.present?
  end

  def send_recommendation_email
    ShareMailer.recommendation_email(self).deliver_now
  end
end
