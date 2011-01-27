module Search::Modules::Ferret::FerretSynonymExtension

  def acts_as_searchable
    extend  Search::Modules::Ferret::FerretMethods::ClassMethods
    include Search::Modules::Ferret::FerretMethods::InstanceMethods

    # We will search both name -> original and original -> name, so index both.
    acts_as_ferret :fields   => { :name => {}, :original => {} },
                   :analyzer => DutchStemmingAnalyzer.new,
                   :remote   => true
  end
end
