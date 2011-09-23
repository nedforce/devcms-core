require 'acts_as_content_node'
require 'routing_helpers'
require 'routing_extensions'
require 'editor_approval_requirement'
require 'acts_as_archive'
require 'date_extensions'
require 'array_extensions'
require 'acts_as_commentable'
require 'caching_extensions'
require 'form_tag_helper_style_fix'
require 'association_preload_fix'
require 'acts_as_archive_controller'
require 'searcher'
require 'recaptcha'
require 'validates_email_format_of'

# Extend ActiveRecord::Base with the +acts_as_content_node+ functionality.
ActiveRecord::Base.send(:include, Acts::ContentNode)

# Extend ActiveRecord::Base with the +acts_as_archive+ functionality.
ActiveRecord::Base.send(:include, Acts::Archive)

ActiveRecord::Base.send(:extend, AssociationPreloadFix)

# Extend ActionView::Base and ActionController::Base to include the +ActionView::Helpers::RoutingHelpers+.
ActionView::Base.send(:include, ActionView::Helpers::RoutingHelpers)
ActionController::Base.send(:include, ActionView::Helpers::RoutingHelpers)

# Extend ActionController::Routing::RouteSet to include the +RoutingExtensions::RouteSetExtensions+.
ActionController::Routing::RouteSet.send :include, RoutingExtensions::RouteSetExtensions

# Extend ActiveRecord::Base to include the +EditorApprovalRequirement+.
ActiveRecord::Base.send(:include, EditorApprovalRequirement)

# Extend ActiveRecord::Base to include +ActsAsCommentable+.
ActiveRecord::Base.send(:include, Juixe::Acts::Commentable)

# Extend ::Date to include the end and start of month/week
Date.send(:include, DateExtensions)

# Extend ::Array to include a set equality check
Array.send(:include, ArrayExtensions)

# Extend ActionView::Helpers::FormTagHelper to make sure form tags do not use inline styles.
ActionView::Base.send(:include, FormTagHelperStyleFix)
ActionView::Base.send(:include, HelperExtensions)

# Extend ActionController::Base to include acts_as_archive_controller
ActionController::Base.send(:include, Acts::ArchiveController)

# Extend ActionView::Base to include a recaptcha helper;
# and extend ActionController::Base to include verification methods for recaptcha.
ActionView::Base.send(:include, Recaptcha::ClientHelper)
ActionController::Base.send(:include, Recaptcha::Verify)
