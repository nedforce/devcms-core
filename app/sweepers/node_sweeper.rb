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
    Node.where(['(:now >= nodes.publication_start_date AND nodes.publication_start_date > nodes.updated_at) OR (:now <= nodes.publication_end_date AND nodes.publication_end_date > nodes.updated_at)', { :now => Time.now }] ).each do |node|
      node.update_attributes :updated_at => Time.now
    end
  end

protected

  def sweep(node)
    # If title, url_alias, show_in_menu, private, deleted_at or ancestry changed, we'll need to expire some things
    if node.content.blank? || (node.changed & %w(title url_alias ancestry show_in_menu private deleted_at publication_start_date publication_end_date)).present? || node.changed == ["updated_at"]
      # But only if we where shown in the menu or are shown there now
      if node.show_in_menu || node.show_in_menu_changed?
        # Expire footer if parent is a site
        controller.expire_fragment(:footer_for_site => node.parent.id) if node.parent.sub_content_type == 'Site'
        # Expire submenu for parent and siblings
        node.parent.self_and_children.where(:show_in_menu => true).each do |n|
          # Disregading visibility, remove both private and public version.
          controller.expire_fragment(:sub_menu_for_node => n.id, :private => true)
          controller.expire_fragment(:sub_menu_for_node => n.id, :private => false)
        end
        node.self_and_descendants.where(:show_in_menu => true).each do |n|
          # Disregading visibility, remove both private and public version.
          controller.expire_fragment(:sub_menu_for_node => n.id, :private => true)
          controller.expire_fragment(:sub_menu_for_node => n.id, :private => false)
        end
        # Expire mainmenu of containing site if in main menu scope of containing site
        controller.expire_fragment(:main_menu_for_site => node.containing_site.id) if node.depth - node.containing_site.depth <= Devcms.main_menu_depth
      end
      # Expire breadcrumbs for self and descendants
      node.self_and_descendants.where(:show_in_menu => true).each do |n|
        controller.expire_fragment(:breadcrumbs_for_node => n.id)
      end
      # Expire slideshow on delete/destroy
      controller.expire_fragment(:header_slideshow_for => node.child_ancestry ) if node.deleted_at.present?
    end

    #TODO: Expire content boxes => based on content type etc. Might be path, parent or grandparent etc..

    if node.sub_content_type == 'Image'
      if (node.parent.present? rescue false)
        if node.content.blank? || node.changed == ["updated_at"] || node.content.is_for_header_changed? || ((node.changed & %w(url_alias ancestry private deleted_at)).present? && node.content.is_for_header)
          controller.expire_fragment(:header_slideshow_for => node.parent.header_container_ancestry ) # Expire parent or ancestor container
          controller.expire_fragment(:header_slideshow_for => node.ancestry ) #expire parent in case the was the last header image for this parent
        end
      end
      controller.expire_page(:host => Settler[:host], :controller => '/images', :action => :thumbnail,          :id => node.content_id, :format => 'jpg')
      controller.expire_page(:host => Settler[:host], :controller => '/images', :action => :header,             :id => node.content_id, :format => 'jpg')
      controller.expire_page(:host => Settler[:host], :controller => '/images', :action => :big_header,         :id => node.content_id, :format => 'jpg')
      controller.expire_page(:host => Settler[:host], :controller => '/images', :action => :full,               :id => node.content_id, :format => 'jpg')
      controller.expire_page(:host => Settler[:host], :controller => '/images', :action => :sidebox,            :id => node.content_id, :format => 'jpg')
      controller.expire_page(:host => Settler[:host], :controller => '/images', :action => :content_box_header, :id => node.content_id, :format => 'jpg')
    end
  end
end
