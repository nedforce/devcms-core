#
# Module EditorApprovalRequirement is used to tell ActtiveRecord classes that they need to be approved when
# created or edited by an editor.
#
module EditorApprovalRequirement

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods

    def needs_editor_approval(options = {})
      attr_accessor :editor_comment
      
      self.class_eval do
        unless self.method_defined?(:original_save)
          alias_method :original_save, :save
        end
        
        def save(*args)
          options = args.extract_options!
          user = options.delete(:user)
    
          user_is_editor = user.present? && !user.has_role_on?(['admin', 'final_editor'], self.new_record? ? self.parent : self.node)
          
          approval_required = options[:approval_required_required].blank? ? false : options[:approval_required]
    
          extra_version_attributes = { :status => Version::STATUSES[self.draft? ? :drafted : :unapproved], :editor => user }
          extra_version_attributes.update(:editor_comment => self.editor_comment) unless self.editor_comment.blank?
    
          self.with_versioning(self.draft? || user_is_editor || approval_required, extra_version_attributes) do
            self.original_save(*args)
          end
        end
  
        def save!(*args)
          self.save(*args) || raise(ActiveRecord::RecordNotSaved)
        end        

        def self.create(attributes = nil, &block)
          if attributes.is_a?(Array)
            super(attributes, &block)
          else
            user = attributes.delete(:user)
            parent = attributes[:parent]

            if user && parent && user.has_role_on?('editor', parent)
              attributes[:responsible_user] = user
            end
            
            approval_required = attributes.delete(:approval_required)
            object = new(attributes)
            yield(object) if block_given?
            object.save(:user => user, :approval_required => approval_required)
            object
          end
        end
        
        def self.create!(attributes = nil, &block)
          self.create(attributes, &block) || raise(ActiveRecord::RecordNotSaved)
        end
        
        def self.requires_editor_approval?
          true
        end
      end
      
      include InstanceMethods
    end
  end
  
  module InstanceMethods

    def update_attributes(attributes)
      user = attributes.delete(:user)
      parent = attributes[:parent]
    
      if user && parent && user.has_role_on?('editor', parent)
        attributes[:responsible_user] = user
      end

      approval_required = attributes.delete(:approval_required)
      self.attributes = attributes
      self.save(:user => user, :approval_required => approval_required)
    end
  
    def update_attributes!(attributes)
      self.update_attributes(attributes) || raise(ActiveRecord::RecordNotSaved)
    end  
      
  end
end

