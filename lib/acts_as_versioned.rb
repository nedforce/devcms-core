class ActiveRecord::Base
  def self.acts_as_versioned(options = {})
    options.assert_valid_keys([ :exclude ])
    
    options.reverse_merge!(:exclude => [ :updated_at, :created_at ])
            
    cattr_accessor :acts_as_versioned_excluded_columns
    
    self.acts_as_versioned_excluded_columns = Array(options[:exclude]).map(&:to_s)
    
    include Acts::Versioned unless self.include?(Acts::Versioned)
  end
end

module Acts
  module Versioned
    def self.included(base)
      base.class_eval do
        include InstanceMethods
        
        has_many :versions, :as => :versionable, :dependent => :delete_all, :autosave => true do
          def current
            self.first
          end
        end

        before_save :acts_as_versioned_before_save_callback
        
        after_save :acts_as_versioned_after_save_callback

        attr_accessor :acts_as_versioned_should_create_version, :acts_as_versioned_extra_version_attributes
      end
    end
    
    module InstanceMethods
      def acts_as_versioned_should_create_version?
        !!acts_as_versioned_should_create_version
      end
      
      def with_versioning(options = {})
        self.acts_as_versioned_should_create_version = options[:should_create_version] || false
        self.acts_as_versioned_extra_version_attributes = options[:extra_version_attributes] || {}
        
        yield self
      ensure
        self.acts_as_versioned_should_create_version = false
        self.acts_as_versioned_extra_version_attributes = {}
      end
      
      
      def unversioned?
        self.versions.unapproved.count.zero?
      end
      
      def versioned?
        !unversioned?
      end
      
      def current_version
        if self.versions.count.zero?
          Version.create_version(self)
        else
          self.versions.first.model
        end
      end
      
      def previous_version
        return nil if self.versions.count.zero?
        
        if self.versions.count == 1
          self.node.publishable? ? Version.create_version(self) : nil
        else
          self.versions.first.model
        end
      end
      
    protected
    
      def acts_as_versioned_before_save_callback
        if self.acts_as_versioned_should_create_version?
          version_attributes = { :yaml => self.attributes.except(*self.class.acts_as_versioned_excluded_columns).to_yaml }
          version_attributes.update(self.acts_as_versioned_extra_version_attributes)
          
          # We currently only keep 1 version
          self.versions.clear
          self.versions.build(version_attributes)
        end
        
        true
      end
      
      def acts_as_versioned_after_save_callback
        unless self.acts_as_versioned_should_create_version?
          self.node.publishable = true unless self.node.publishable?
          self.versions.clear unless self.versions.count.zero?
        end
        
        true
      end
      
    private
    
      # Only update the model in the database if the changes are not versioned
      def update_without_callbacks
        super unless self.acts_as_versioned_should_create_version?
      end
    end
  end 
end