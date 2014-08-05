# This model is used to represent a social media links box that
# contains links to social media sites. It has specified
# +acts_as_content_node+ from Acts::ContentNode::ClassMethods.
#
# *Specification*
# 
# Attributes
# 
# * +title+        - The title of the social media links box.
# * +twitter_url+  - A Twitter URL.
# * +facebook_url+ - A Facebook URL.
# * +linkedin_url+ - A LinkedIn URL.
# * +youtube_url+  - A YouTube URL.
# * +flickr_url+   - A Flickr URL.
#
# Preconditions
#
# * Requires the presence of +title+.
# * Requires the URLs to be valid if they are present.
#
class SocialMediaLinksBox < ActiveRecord::Base
  # Adds content node functionality to social media links boxes.
  acts_as_content_node({
    allowed_roles_for_create:          %w( admin ),
    allowed_roles_for_update:          %w( admin ),
    allowed_roles_for_destroy:         %w( admin ),
    available_content_representations: ['content_box'],
    show_in_menu:                      false,
    copyable:                          false
  })

  VALID_URL_REGEXP = /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.([a-z]{2,5}|[0-9]{1,5})(\/.*)?$)/ix

  # See the preconditions overview for an explanation of these validations.
  validates :title, presence: true, length: { in: 2..255 }

  validates_format_of :twitter_url, :facebook_url, :linkedin_url, :with => VALID_URL_REGEXP, :allow_blank => true
  validates_format_of :youtube_url, :flickr_url,                  :with => VALID_URL_REGEXP, :allow_blank => true
end
