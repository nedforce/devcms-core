module NodeExtensions::MoveToWithReindexing
  extend ActiveSupport::Concern

  module ClassMethods

    def move_to(target, position)
      super(target, position)
      reindex_self_and_children
    end

  end

end