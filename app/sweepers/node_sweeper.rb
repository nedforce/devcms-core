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

protected

  def sweep(node)
    if Node.content_type_configuration(node.sub_content_type)[:show_in_menu] && node.show_in_menu
      controller.expire_fragment(:host => Settler[:host], :controller => '/nodes', :action => :footer,    :site => node.containing_site.id) if node.ancestry_depth <= 1
      controller.expire_fragment(:host => Settler[:host], :controller => '/nodes', :action => :main_menu, :site => node.containing_site.id) if node.ancestry_depth <= 2  
    end

    if node.sub_content_type == 'Image'
      controller.expire_page(:host => Settler[:host], :controller => '/images', :action => :thumbnail,          :id => node.content_id, :format => 'jpg')
      controller.expire_page(:host => Settler[:host], :controller => '/images', :action => :header,             :id => node.content_id, :format => 'jpg')
      controller.expire_page(:host => Settler[:host], :controller => '/images', :action => :big_header,         :id => node.content_id, :format => 'jpg')
      controller.expire_page(:host => Settler[:host], :controller => '/images', :action => :full,               :id => node.content_id, :format => 'jpg')
      controller.expire_page(:host => Settler[:host], :controller => '/images', :action => :sidebox,            :id => node.content_id, :format => 'jpg')
      controller.expire_page(:host => Settler[:host], :controller => '/images', :action => :content_box_header, :id => node.content_id, :format => 'jpg')
    end
  end
end
