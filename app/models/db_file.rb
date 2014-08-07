# This model serves to store file uploads with the attachment_fu plugin.
# It is called DbFile as per the attachment_fu convention. The attachments
# themselves are to be accessed through the +Attachment+ model.
#
# *Specification*
# 
# Attributes
# 
# * +attachment+ - The metadata belonging to this file.
# * +loid+ - The binary file data (A PostgreSQL Large object id)
#
# NOTE: The attachment_fu plugin is edited so it allows the use of
#       PostgreSQL's Large Objects, instead of using the byte array.
#
# Preconditions
#
# * Requires the presence of +loid+.
#
# Postconditions
# 
# * Will destroy +attachment+ when this file is destroyed.
#
class DbFile < ActiveRecord::Base
  has_one :attachment, dependent: :destroy

  # See the preconditions overview for an explanation of these validations.
  validates :loid, presence: true
end
