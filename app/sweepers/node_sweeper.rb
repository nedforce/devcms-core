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
    content = node.content
    
    if Node.content_type_configuration(content.class.name)[:show_in_menu]
      expire_fragment(:controller => '/nodes', :action => :footer, :site => node.containing_site.id) if node.ancestry_depth <= 1
      expire_fragment(:controller => '/nodes', :action => :main_menu, :site => node.containing_site.id) if node.ancestry_depth <= 2  
    end
    
    if content.is_a?(Image)
      expire_page(:controller => "/images", :action => :thumbnail, :id => content.id, :format => 'jpg')
      expire_page(:controller => "/images", :action => :header, :id => content.id, :format => 'jpg')
      expire_page(:controller => "/images", :action => :big_header, :id => content.id, :format => 'jpg')
      expire_page(:controller => "/images", :action => :full, :id => content.id, :format => 'jpg')
      expire_page(:controller => "/images", :action => :sidebox, :id => content.id, :format => 'jpg')
      expire_page(:controller => "/images", :action => :content_box_header, :id => content.id, :format => 'jpg')
    end
  end
end
