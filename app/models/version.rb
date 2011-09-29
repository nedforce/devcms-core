# SimplyVersioned 0.9.3
#
# Simple ActiveRecord versioning
# Copyright (c) 2007,2008 Matt Mower <self@mattmower.com>
# Released under the MIT license (see accompany MIT-LICENSE file)
#
# Edited by Gerjan Stokkink

# A Version represents a numbered revision of an ActiveRecord model.
#
# The version has two attributes +number+ and +yaml+ where the yaml attribute
# holds the representation of the ActiveRecord model attributes. To access
# these call +model+ which will return an instantiated model of the original
# class with those attributes.
#
class Version < ActiveRecord::Base #:nodoc:
  STATUSES = {
    :drafted => 'drafted',
    :unapproved => 'unapproved',
    :rejected => 'rejected'
  }
  
  belongs_to :versionable, :polymorphic => true
  belongs_to :editor, :class_name => 'User'
  
  validates_presence_of :status
  validates_inclusion_of :status, :in => STATUSES.values
  
  named_scope :unapproved, { :conditions => [ "status = ? OR status = ?", STATUSES[:unapproved], STATUSES[:rejected] ], :order => "created_at DESC" }
  
  before_create :set_number
  
  def drafted?
    self.status == STATUSES[:drafted]
  end
  
  def unapproved?
    self.status == STATUSES[:unapproved]
  end
  
  def rejected?
    self.status == STATUSES[:rejected]
  end
  
  def approve!(user = nil)
    if user
      self.model.save :user => user
    else
      self.model.save
    end
  end
  
  def reject!
    self.update_attributes(:status => STATUSES[:rejected])
  end
  
  # Return an instance of the versioned ActiveRecord model with the attribute
  # values of this version.
  def model
    Version.create_version(self.versionable, YAML::load(self.yaml).merge(:draft => self.drafted?))
  end
  
  def self.create_version(original, attributes_to_overwrite = {})
    obj = original.class.find(original.id)
    
    attributes_to_overwrite.except(*original.simply_versioned_excluded_columns).each do |name, value|
      # rescue to ignore things we cannot deserialize anymore; this may happen
      # after a schema change for the stored content (e.g. a attribute is
      # removed).
      obj.__send__("#{name}=", value) rescue value
    end

    obj
  end
  
  # Return the next higher numbered version, or nil if this is the last version
  def next
    versionable.versions.next_version(self.number)
  end
  
  # Return the next lower numbered version, or nil if this is the first version
  def previous
    versionable.versions.previous_version(self.number)
  end

protected
  def set_number
    if versionable.versions.empty?
      self.number = 1
    else
      self.number = versionable.versions.maximum(:number) + 1
    end
  end
  
end
