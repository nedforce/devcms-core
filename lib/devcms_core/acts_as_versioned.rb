module DevcmsCore
  module ActsAsVersioned
    extend ActiveSupport::Concern

    included do
      has_many :versions, :as => :versionable, :dependent => :delete_all, :autosave => true do
        def current
          first
        end
      end

      before_save :acts_as_versioned_before_save_callback
      after_save :acts_as_versioned_after_save_callback
      attr_accessor :acts_as_versioned_should_create_version, :acts_as_versioned_extra_version_attributes
    end

    def acts_as_versioned_should_create_version?
      !!acts_as_versioned_should_create_version
    end

    def with_versioning(options = {})
      self.acts_as_versioned_should_create_version    = options[:should_create_version]    || false
      self.acts_as_versioned_extra_version_attributes = options[:extra_version_attributes] || {}

      yield self
    ensure
      self.acts_as_versioned_should_create_version    = false
      self.acts_as_versioned_extra_version_attributes = {}
    end

    def unversioned?
      versions.unapproved.count.zero?
    end

    def versioned?
      !unversioned?
    end

    def current_version
      if versions.count.zero?
        Version.create_version(self)
      else
        versions.first.model
      end
    end

    def previous_version
      return nil if versions.count.zero?

      if versions.count == 1
        node.publishable? ? Version.create_version(self) : nil
      else
        versions.first.model
      end
    end

  protected

    def acts_as_versioned_before_save_callback
      if acts_as_versioned_should_create_version?
        version_attributes = { :yaml => self.attributes.except(*self.class.acts_as_versioned_excluded_columns).to_yaml }
        version_attributes.update(self.acts_as_versioned_extra_version_attributes)

        # We currently only keep 1 version
        versions.clear
        versions.build(version_attributes)
        assign_attributes(changed_attributes) if persisted? && node.publishable?
      else
        node.publishable = true unless node.publishable?
      end

      true
    end

    def acts_as_versioned_after_save_callback
      # TODO: refactor double unless
      unless acts_as_versioned_should_create_version?
        versions.clear unless versions.count.zero?
      end

      true
    end
  end
end
