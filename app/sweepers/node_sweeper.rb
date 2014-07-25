class NodeSweeper < ActionController::Caching::Sweeper
  observe Node

  def after_create(node)
    sweep(node)
  end

  def after_destroy(node)
    sweep(node)
  end

  def after_update(node)
    sweep(node)
  end

  def self.sweep_nodes
    Node.where(['(:now >= nodes.publication_start_date AND nodes.publication_start_date > nodes.updated_at) OR (:now <= nodes.publication_end_date AND nodes.publication_end_date > nodes.updated_at)', { :now => Time.now }]).each do |node|
      node.update_attributes :updated_at => Time.now
    end
  end

protected

  def sweep(node)
    # If title, url_alias, show_in_menu, private, deleted_at or ancestry changed, we'll need to expire some things
    if node.content.blank? || (node.changed & %w(title url_alias ancestry show_in_menu private deleted_at publication_start_date publication_end_date position layout_configuration)).present? || node.changed == ['updated_at']
      # But only if we where shown in the menu or are shown there now
      if node.show_in_menu || node.show_in_menu_changed?
        if node.parent.present?
          # Expire footer if parent is a site
          expire_fragment(:footer_for_site => node.parent.id) if node.parent.sub_content_type == 'Site'
        end
        # Expire mainmenu of containing site if in main menu scope of containing site
        expire_fragment(:main_menu_for_site => node.containing_site.id) if node.depth - node.containing_site.depth <= Devcms.main_menu_depth
      end
      # Expire slideshow on delete/destroy
      expire_fragment(:header_slideshow_for => node.child_ancestry) if node.layout_configuration_changed? || node.deleted_at.present?
    end

    #TODO: Expire content boxes => based on content type etc. Might be path, parent or grandparent etc.

    if node.sub_content_type == 'Image'
      if (node.parent.present? rescue false)
        if node.content.blank? || node.changed == ['updated_at'] || node.content.is_for_header_changed? || ((node.changed & %w(url_alias ancestry private deleted_at)).present? && node.content.is_for_header)
          expire_fragment(:header_slideshow_for => node.parent.header_container_ancestry) # Expire parent or ancestor container
          expire_fragment(:header_slideshow_for => node.ancestry) # Expire parent in case the was the last header image for this parent
        end
      end
      expire_page(:host => Settler[:host], :controller => '/images', :action => :thumbnail,  :id => node.content_id, :format => 'jpg')
      expire_page(:host => Settler[:host], :controller => '/images', :action => :header,     :id => node.content_id, :format => 'jpg')
      expire_page(:host => Settler[:host], :controller => '/images', :action => :big_header, :id => node.content_id, :format => 'jpg')
      expire_page(:host => Settler[:host], :controller => '/images', :action => :full,       :id => node.content_id, :format => 'jpg')
      expire_page(:host => Settler[:host], :controller => '/images', :action => :sidebox,    :id => node.content_id, :format => 'jpg')
      expire_page(:host => Settler[:host], :controller => '/images', :action => :banner,     :id => node.content_id, :format => 'jpg')
    end
  end
end
