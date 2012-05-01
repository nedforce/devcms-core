# Core extensions
require 'devcms_core/object_extensions'
require 'devcms_core/array_extensions'
require 'devcms_core/date_extensions'
require 'devcms_core/sweeper_fix'
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
require 'sortable'
require 'spreadsheet'
require 'roo'
require 'ferret'
require 'RMagick'
require 'exception_notification'
require 'kaminari'
require 'sanitize'
require 'geokit'
require 'geokit-rails'
require 'redhillonrails_core'
require 'foreign_key_migrations'
require 'carrierwave'
require 'ssl_requirement'
require 'rack/rewrite'
require 'pg'
require 'prototype-rails'
require 'prototype_legacy_helper'
require 'tidy_ffi'

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
  autoload :CalendarItemsAssociationExtensions
  autoload :ContentTypeConfiguration
  autoload :DutchStemmingAnalyzer
  autoload :EngineExtensions
  autoload :Hijacker
  autoload :ImageProcessingExtensions
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