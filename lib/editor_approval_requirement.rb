#
# Module EditorApprovalRequirement is used to tell ActtiveRecord classes that they need to be approved when
# created or edited by an editor.
#
# To specify that a model has an editor approval requirement:
#
# - Add a column 'status' to the ActiveRecord: add_column <table>, :status, :string (, :default => 'approved')
# - Add the method call 'needs_editor_approval' to the model
#
#
module EditorApprovalRequirement

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods

    def needs_editor_approval

      # Keep 1 version
      simply_versioned :keep => 1, :automatic => false

      self.class_eval do

        def editor_comment=(value)
          @editor_comment = value
        end

        def editor_comment
          if self.new_record?
            @editor_comment
          else
            @editor_comment || self.node.editor_comment
          end
        end

        # Create accessor to make this object a draft if requested by an editor
        def draft=(value)
          @draft = (value == "1") ? true : false
        end

        def draft
          @draft = self.node.drafted? if @draft.nil? && !self.new_record?
          @draft || false
        end

        # Saves the content node and moves it at the given position relative to the specified node.
        # Also sets the approval state for the given user, and handles versioning if appropriate.
        # If +rescue_exceptions+ is true (the default), any thrown +ActiveRecord::ActiveRecordError+ exceptions on save will be rescued.
        # If +skip_approval+ is true, then the content is not automatically approved when updated by an admin or final editor
        # If a block is passed in, then that block is executed instead of calling +self.save+, note that this block must return a boolean to indicate success
        def save_for_user(user, skip_approval = false, &block)          
          role_node = self.new_record? ? self.parent : self
          
          saved = self.with_versioning(!self.new_record? && (!user.has_role_on?(['admin','final_editor'], role_node) || skip_approval)) do
            if block_given?
              yield
            else
              self.save
            end
          end

          # set approval state and editor comment
          if saved
            set_approval_state_for_user(user, skip_approval)
            set_editor_comment
          end

          saved
        end
        
        def save_for_user!(user, skip_approval = false)
          self.save_for_user(user, skip_approval) do
            self.save!
          end
        end

        # this method should be used instead of update_attributes to update a record
        # If +skip_approval+ is true, then the content is not automatically approved when updated by an admin or final editor
        def update_attributes_for_user(user, attributes, skip_approval = false)
          self.save_for_user(user, skip_approval) do
            self.update_attributes(attributes)
          end
        end

        # this method should be used instead of update_attributes to update a record
        # If +skip_approval+ is true, then the content is not automatically approved when updated by an admin or final editor
        def update_attributes_for_user!(user, attributes, skip_approval = false)
          self.save_for_user(user, skip_approval) do
            self.update_attributes!(attributes)
          end
        end

        # Creates a new content node with the given attribute hash and moves it at the given position relative to the specified node.
        # Also sets the approval state for the given user, and handles versioning if appropriate.
        # If +rescue_exceptions+ is true (the default), any thrown +ActiveRecord::ActiveRecordError+ exceptions on save
        def self.create_for_user(user, attributes)
          new_object = self.new(attributes)
          new_object.save_for_user(user)
          new_object
        end

        def set_editor_comment
          self.node.update_attribute(:editor_comment, @editor_comment)
        end

        def set_approval_state_for_user(user, skip_approval)
          if self.draft
            self.node.draft!
          else
            self.node.set_approval_state_for_user(user, skip_approval)
          end
        end

        def previous_version
          if versioned?
            model      = self.versions.current.model
            model.node = self.node
            model
          else
            nil
          end
        end

        def approved?
          self.node.approved?
        end

        def approved_version
          if self.approved?
            self
          else
            self.previous_version
          end
        end

        def is_versioned?
          versioned?
        end

        def create_approved_version
          self.with_versioning(true) { self.save }
        end
      end
    end
  end
end

