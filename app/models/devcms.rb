class Devcms
  class << self
    def content_types_configuration
      {}
    end

    # Returns a hash representing this node's config properties for an Ext.dvtr.AsyncTreeNode JavaScript object.
    # The hash returned will be reverse merged with node.to_tree_node_for(user)
    def tree_node_for(node, user, options = {})
      {}
    end

    def search_configuration
      return { enabled_search_engines: [] } unless SETTLER_LOADED

      {
        enabled_search_engines: ['ferret'],
        default_search_engine:  'ferret',
        default_page_size:      Settler[:search_default_page_size].to_i,
        ferret: {
          synonym_weight: Settler[:search_ferret_synonym_weight].to_f,
          proximity:      Settler[:search_ferret_proximity].to_f
        }
      }
    end

    def content_box_colours
      %w( default )
    end

    def content_box_icons
      %w( )
    end

    def reserved_logins_regex
      /(burger?meester|wethouder|gemeente|stads|student|leerling|voorlichting|communicatie|openba?are?|brandweer|politie|ambulance|ggz|ggd|ziekenhuis|school|hospitaal|gemeente|college|stadhuis)/i
    end

    def main_menu_depth
      2
    end

    def node_locales
      {
        'Nederlands' => 'nl',
        'Engels'     => 'en',
        'Duits'      => 'de',
        'Spaans'     => 'es',
        'Frans'      => 'fr'
      }
    end
  end
end
