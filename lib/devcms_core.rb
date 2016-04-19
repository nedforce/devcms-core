# Core extensions
require 'devcms_core/object_extensions'
require 'devcms_core/array_extensions'
require 'devcms_core/date_extensions'
require 'devcms_core/string_extensions'
require 'devcms_core/diff'

# Dependencies
require 'acts-as-taggable-on'
require 'addressable/uri'
require 'ancestry'
require 'dsl_accessor'
require 'dynamic_attributes'
require 'feed-normalizer'
require 'haml'
require 'libxml'
require 'settler'
require 'acts_as_list'
require 'roo'
require 'kaminari'
require 'sanitize'
require 'schema_plus'
require 'carrierwave'
require 'rack/rewrite'
require 'pg'
require 'prototype-rails'
require 'jquery-rails'
require 'jquery-ui-rails'
require 'devcms_core/prototype_legacy_helper'
require 'tidy_ffi'
require 'truncate_html'
require 'secure_headers'
require 'airbrake'
require 'rails-observers'
require 'action_controller/page_caching'

# Libs
module DevcmsCore
  extend ActiveSupport::Autoload

  autoload :ActiveRecordExtensions
  autoload :ActionControllerExtensions
  autoload :ActsAsCommentable
  autoload :ActsAsContentNode
  autoload :ActsAsArchive
  autoload :ActsAsVersioned
  autoload :NeedsEditorApproval
  autoload :ActsAsArchiveController
  autoload :AttachmentTestHelper
  autoload :AuthenticatedSystem
  autoload :AuthenticatedTestHelper
  autoload :Blowfish
  autoload :TokenGeneration
  autoload :CalendarItemsAssociationExtensions
  autoload :ContentTypeConfiguration
  autoload :ContentNodeCheckerRunner
  autoload :DutchStemmingAnalyzer
  autoload :EngineExtensions
  autoload :Hijacker
  autoload :ImageProcessingExtensions
  autoload :MailUtils
  # autoload :NewsItemsAssociationExtensions
  # autoload :PrototypeLegacyHelper
  autoload :Recaptcha
  autoload :RespondsToParent
  autoload :RoleRequirementSystem
  autoload :RoleRequirementTestHelper
  autoload :RoutingHelpers
  autoload :Rewriter
end

class Rails::Engine
  include DevcmsCore::EngineExtensions
end

require 'devcms_core/engine'
