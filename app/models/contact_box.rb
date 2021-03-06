# A contact box is a content node that displays contact information when placed
# in a sidebar. It has specified +acts_as_content_node+ from
# Acts::ContentNode::ClassMethods.
#
# *Specification*
#
# Attributes
#
# * +title+ - The title.
# * +contact_information+ - Contact information text.
# * +default_text+ - The default text.
# * +monday_text+ - The optional overriding text for (next) monday.
# * +tuesday_text+ - The optional overriding text for (next) tuesday.
# * +wednesday_text+ - The optional overriding text for (next) wednesday.
# * +thursday_text+ - The optional overriding text for (next) thursday.
# * +friday_text+ - The optional overriding text for (next) friday.
# * +saturday_text+ - The optional overriding text for (next) saturday.
# * +sunday_text+ - The optional overriding text for (next) sunday.
#
# Preconditions
#
# * Requires the presence of +title+.
# * Requires the presence of +contact_information+.
# * Requires the presence of +default_text+.
#
# Child/parent type constraints
#
#  * A +TopHitsPage+ does not accept any child nodes.
#  * A +TopHitsPage+ can be inserted into nodes of any accepting type.
#
class ContactBox < ActiveRecord::Base
  # Adds content node functionality to contact boxes.
  acts_as_content_node({
    allowed_child_content_types:       %w( Image ),
    show_in_menu:                      false,
    allowed_roles_for_create:          %w( admin ),
    allowed_roles_for_destroy:         %w( admin ),
    available_content_representations: ['content_box'],
    show_content_box_header:           false
  })

  # See the preconditions overview for an explanation of these validations.
  validates :title,               presence: true, length: { in: 3..255 }
  validates :contact_information, presence: true, length: { minimum: 3 }
  validates :default_text,        presence: true, length: { minimum: 3 }

  validates_length_of :monday_text,
                      :tuesday_text,
                      :wednesday_text,
                      :thursday_text,
                      :friday_text,
                      :saturday_text,
                      :sunday_text,
                      minimum:     3,
                      allow_blank: true

  def selected_more_addresses_url
    if more_addresses_url.present?
      more_addresses_url
    elsif Settler[:contact_box_more_addresses_url].present?
      Settler[:contact_box_more_addresses_url]
    else
      '/contact'
    end
  end

  def selected_more_times_url
    if more_times_url.present?
      more_times_url
    elsif Settler[:contact_box_more_times_url].present?
      Settler[:contact_box_more_times_url]
    else
      selected_more_addresses_url
    end
  end
end
