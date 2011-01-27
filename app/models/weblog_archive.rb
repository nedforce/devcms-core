# This model is used to represent a weblog archive that can contain multiple
# weblogs, which are represented using +Weblog+ objects. It has specified
# +acts_as_content_node+ from Acts::ContentNode::ClassMethods.
#
# *Specification*
#
# Attributes
#
# * +title+ - The title of the weblog archive.
# * +description+ - The description of the weblog archive.
#
# Preconditions
#
# * Requires the presence of +title+.
#
# Child/parent type constraints
#
#  * A WeblogArchive only accepts +Weblog+ children.
class WeblogArchive < ActiveRecord::Base

  # Determines how many +Weblog+ nodes are shown for each offset node in the admin controller.
  DEFAULT_OFFSET = 20

  # Adds content node functionality to weblog archives.
  acts_as_content_node({
    :allowed_child_content_types => %w( Weblog ),
    :allowed_roles_for_create  => %w( admin ),
    :allowed_roles_for_destroy => %w( admin ),
    :available_content_representations => ['content_box'],
    :children_can_be_sorted => false,
    :tree_loader_name => 'weblog_archives'
  })

  # A +WeblogArchive+ can have many +Weblog+ children.
  has_children :weblogs, :order => 'title'

  # See the preconditions overview for an explanation of these validations.
  validates_presence_of :title
  validates_length_of   :title, :in => 2..255

  # Finds the first +DEFAULT_OFFSET+ weblogs belonging to this +WeblogArchive+,
  # starting at the given +offset+.
  def find_weblogs_for_offset(offset)
    self.weblogs.all(:offset => offset, :limit => DEFAULT_OFFSET)
  end

  # Returns a hash with the offsets that can be used in subsequent calls to
  # +find_weblogs_for_offset+.
  #
  # Each offset returned is a multiple of +DEFAULT_OFFSET+, and never exceeds the total
  # number of weblogs for this +WeblogArchive+.
  #
  # For example, with +DEFAULT_OFFSET+ equal to 20 and the total number of weblogs
  # being 67, the following result will be returned:
  #
  # [ 0, 20, 40, 60 ]
  def find_offsets
    offsets = []

    0.upto(self.weblogs.count / DEFAULT_OFFSET) do |i|
      offsets << i * 20
    end

    offsets
  end

  # Finds the first and last +Weblog+ for the range determined by the given +offset+.
  #
  # For example, with +DEFAULT_OFFSET+ equal to 20, +offset+ equal to 40 and the
  # total number of weblogs being 57, the 41st and 57th weblogs will be returned.
  def find_first_and_last_weblog_for_offset(offset)
    first  = self.weblogs.first(:offset => offset, :limit => DEFAULT_OFFSET)
    second = self.weblogs.first(:offset => offset, :limit => DEFAULT_OFFSET, :order => 'title DESC')

    [ first, second ]
  end

  # Parses the given +offset+.
  # Returns 0 if the given +offset+ is smaller than zero, else rounds it down to the
  # nearest multiple of +DEFAULT_OFFSET+ (possibly 0 if +offset+ < +DEFAULT_OFFSET+)
  def self.parse_offset(offset)
    if offset < DEFAULT_OFFSET
      0
    else
      (offset / DEFAULT_OFFSET) * DEFAULT_OFFSET
    end
  end

  # Returns true if this +WeblogArchive+ has a +Weblog+ associated with the given +User+, else false.
  def has_weblog_for_user?(user)
    self.weblogs.exists?(:user_id => user)
  end

  # Finds the +limit+ last updated +Weblog+ children.
  # TODO: this query is slow because it instantiates all weblogs. Should be replaced by a faster custom SQL query, if possible.
  def find_last_updated_weblogs(user, limit)
    limit ||= 5
    return [] if limit <= 0
    self.weblogs.find_accessible(:all, :for => user).sort { |a, b| b.last_updated_at(user) <=> a.last_updated_at(user) }[0.. (limit - 1)]
  end

  # Returns the description as the token for indexing.
  def content_tokens
    description
  end

  # Returns the OWMS type.
  def self.owms_type
    I18n.t('owms.overview_page')
  end
end
