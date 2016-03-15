module DevcmsCore
  module ActsAsCommentable
    extend ActiveSupport::Concern

    module ClassMethods
      def acts_as_commentable
        has_many :comments, ->{ order(created_at: :asc) }, as: :commentable, dependent: :destroy
      end

      # Helper method to lookup for comments for a given object.
      # This method is equivalent to obj.comments.
      def find_comments_for(obj)
        commentable = ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s

        Comment.find(:all,
          :conditions => ['commentable_id = ? and commentable_type = ?', obj.id, commentable],
          :order => 'created_at DESC'
        )
      end
    end

    # Helper method to sort comments by date
    def comments_ordered_by_submitted
      Comment.find(:all,
        :conditions => ['commentable_id = ? and commentable_type = ?', id, self.type.name],
        :order => 'created_at DESC'
      )
    end

    # Helper method that defaults the submitted time.
    def add_comment(comment)
      comments << comment
    end
  end
end
