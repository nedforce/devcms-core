class Share < ActiveRecord::Base
  # Some methods to create a tableless ActiveRecord model.
  # See http://railscasts.com/episodes/193-tableless-model for more info.
  def self.columns() @columns ||= []; end

  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end

  column :node_id,            :integer
  column :from_email_address, :string
  column :from_name,          :string
  column :to_email_address,   :string
  column :to_name,            :string
  column :message,            :text

  belongs_to :node

  # See the preconditions overview for an explanation of these validations.
  validates_presence_of     :from_email_address, :to_email_address, :from_name, :to_name, :node, :message
  validates_email_format_of :from_email_address, :to_email_address, :allow_blank => true

  def subject
    if self.node.present? && self.node.approved_content.present?
      self.node.approved_content.title
    else
      nil
    end
  end

  def send_recommendation_email
    ShareMailer.deliver_recommendation_email(self)
  end
end