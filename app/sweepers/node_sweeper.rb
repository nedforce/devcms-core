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
