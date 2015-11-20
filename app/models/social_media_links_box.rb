# This model is used to represent a social media links box that
# contains links to social media sites. It has specified
# +acts_as_content_node+ from Acts::ContentNode::ClassMethods.
#
# *Specification*
#
# Attributes
#
# * +title+         - The title of the social media links box.
# * +facebook_url+  - A Facebook URL.
# * +flickr_url+    - A Flickr URL.
# * +instagram_url+ - An Instagram URL.
# * +linkedin_url+  - A LinkedIn URL.
# * +twitter_url+   - A Twitter URL.
# * +youtube_url+   - A YouTube URL.
#
# Preconditions
#
# * Requires the presence of +title+.
# * Requires the URLs to be valid if they are present.
#
class SocialMediaLinksBox < ActiveRecord::Base
  # Adds content node functionality to social media links boxes.
  acts_as_content_node(
    allowed_roles_for_create:          %w( admin ),
    allowed_roles_for_update:          %w( admin ),
    allowed_roles_for_destroy:         %w( admin ),
    available_content_representations: ['content_box'],
    show_in_menu:                      false,
    copyable:                          false
  )

  VALID_URL_REGEXP = /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.([a-z]{2,5}|[0-9]{1,5})(\/.*)?$)/ix

  # See the preconditions overview for an explanation of these validations.
  validates :title,         presence: true, length: { maximum: 255 }
  validates :facebook_url,  format: { with: VALID_URL_REGEXP, allow_blank: true }
  validates :flickr_url,    format: { with: VALID_URL_REGEXP, allow_blank: true }
  validates :instagram_url, format: { with: VALID_URL_REGEXP, allow_blank: true }
  validates :linkedin_url,  format: { with: VALID_URL_REGEXP, allow_blank: true }
  validates :twitter_url,   format: { with: VALID_URL_REGEXP, allow_blank: true }
  validates :youtube_url,   format: { with: VALID_URL_REGEXP, allow_blank: true }
end
