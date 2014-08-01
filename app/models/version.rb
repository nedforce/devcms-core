class Version < ActiveRecord::Base #:nodoc:
  STATUSES = {
    :drafted    => 'drafted',
    :unapproved => 'unapproved',
    :rejected   => 'rejected'
  }

  UNAPPROVED_STATUSES = ['unapproved', 'rejected']

  belongs_to :versionable, :polymorphic => true
  belongs_to :editor, :class_name => 'User'

  validates :status, :presence => true, :inclusion => { :in => STATUSES.values }

  before_create :set_number

  default_scope :order => 'versions.created_at DESC'

  scope :unapproved, lambda { where(:status => UNAPPROVED_STATUSES) }

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
    klass = original.class

    record = klass.with_exclusive_scope do
      klass.find(original.id)
    end

    attributes_to_overwrite.except(*klass.acts_as_versioned_excluded_columns).each do |name, value|
      record.send("#{name}=", value) rescue nil
    end

    record
  end

protected

  def set_number
    if self.versionable.versions.count.zero?
      self.number = 1
    else
      self.number = self.versionable.versions.maximum(:number) + 1
    end
  end
end
