# An AgendaItemCategory is used to group common agenda items. Thus, it can contain 
# many agenda items, each represented with the AgendaItem content type.
# 
# *Specification*
# 
# Attributes
# 
# * +agenda_items+ - The agenda items that belong to this category.
# * +name+ - The name of this category.
#
# Preconditions
#
# * Requires +name+ to be present.
# * Requires the uniqueness of +name+.
#
class AgendaItemCategory < ActiveRecord::Base

  # The agenda items that belong to this category.
  has_many :agenda_items, :dependent => :nullify

  # See the preconditions overview for an explanation of these validations.
  validates_presence_of   :name
  validates_length_of     :name, :in => 2..255
  validates_uniqueness_of :name

  # Finds the agenda item category with the given name, or initializes a new one with
  # that name (but does *not* save it).
  def self.find_or_new_by_name(name)
    AgendaItemCategory.find_by_name(name) || AgendaItemCategory.new(:name => name)
  end
end
