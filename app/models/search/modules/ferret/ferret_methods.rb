module Search::Modules::Ferret::FerretMethods

  module ClassMethods

    def without_reindex(&block)
      self.disable_ferret &block
    end

  end

  module InstanceMethods

    def without_reindex(&block)
      self.disable_ferret &block
    end

    def update_index
      self.ferret_update
    end

    def disable_reindex_until_saved
      self.disable_ferret :once
    end

    def add_to_index
      self.ferret_create
    end

  end

end
