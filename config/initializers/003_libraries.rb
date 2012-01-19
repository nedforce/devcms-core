# Various fixes, these have to be checked for redundantness every time we upgrade Rails
require 'form_tag_helper_style_fix'
require 'association_preload_fix'
require 'update_all_and_delete_all_scope_fix'

require 'has_one_association_fix'
require 'test_process_fix'
require 'sweeper_fix'

require 'date_extensions'
require 'array_extensions'

require 'acts_as_content_node'
require 'needs_editor_approval'
require 'acts_as_archive'
require 'acts_as_commentable'
require 'acts_as_versioned'
require 'validates_email_format_of'

require 'routing_helpers'
require 'routing_extensions'
require 'cache_extensions' if defined?(Memcached)

require 'acts_as_archive_controller'
require 'searcher'
require 'recaptcha'

# Extend ActiveRecord::Base with the +acts_as_archive+ functionality.
ActiveRecord::Base.send(:include, Acts::Archive)

ActiveRecord::Base.send(:extend, AssociationPreloadFix)

# Extend ActionView::Base and ActionController::Base to include the +ActionView::Helpers::RoutingHelpers+.
ActionView::Base.send(:include, ActionView::Helpers::RoutingHelpers)
ActionController::Base.send(:include, ActionView::Helpers::RoutingHelpers)

# Extend ActionController::Routing::RouteSet to include the +RoutingExtensions::RouteSetExtensions+.
ActionController::Routing::RouteSet.send :include, RoutingExtensions::RouteSetExtensions

# Extend ActiveRecord::Base to include +ActsAsCommentable+.
ActiveRecord::Base.send(:include, Juixe::Acts::Commentable)

# Extend ActionView::Helpers::FormTagHelper to make sure form tags do not use inline styles.
ActionView::Base.send(:include, FormTagHelperStyleFix)
ActionView::Base.send(:include, HelperExtensions)

# Extend ActionController::Base to include acts_as_archive_controller
ActionController::Base.send(:include, Acts::ArchiveController)

# Extend ActionView::Base to include a recaptcha helper;
# and extend ActionController::Base to include verification methods for recaptcha.
ActionView::Base.send(:include, Recaptcha::ClientHelper)
ActionController::Base.send(:include, Recaptcha::Verify)
