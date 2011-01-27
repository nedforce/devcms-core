class DevCMS

  class << self

    #  The hash returned by this method is reverse deep-merged with Node::DEFAULT_CONTENT_TYPES_CONFIGURATION
    def content_types_configuration
      {}
    end

    # Returns a hash representing this node's config properties for an Ext.dvtr.AsyncTreeNode javascript object.
    # The hash returned will be reverse merged with node.to_tree_node_for(user)
    def tree_node_for(node, user, options = {})
      {}
    end
    
    def search_configuration
      {
        :enabled_search_engines => Settler[:search_enabled_engines], 
        :default_search_engine => Settler[:search_default_engine],
        :default_page_size => Settler[:search_default_page_size].to_i,        
        :ferret => {
          :synonym_weight => Settler[:search_ferret_synonym_weight].to_f,
          :proximity => Settler[:search_ferret_proximity].to_f
        },
        :luminis => {
          :luminis_crawler_ips => Settler[:search_luminis_crawler_ips],
          :solr_base_url => Settler[:search_luminis_solr_base_url],
          :solr_connection_timeout => Settler[:search_luminis_connection_timeout].to_i,
          :title_boost => Settler[:search_luminis_title_boost].to_i,
          :synonyms_boost => Settler[:search_luminis_synonyms_boost].to_i,          
          :date_boost => Settler[:search_luminis_date_boost].to_i
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
    
    def core_root
      File.join(Rails.root, 'vendor', 'plugins', 'devcms-core')
    end    
  end
end