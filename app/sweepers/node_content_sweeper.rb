class NodeContentSweeper < ActionController::Caching::Sweeper
  observe Image

  def after_destroy(image)
    sweep(image)
  end

  def after_update(image)
    sweep(image)
  end

  protected

  def sweep(image)
    expire_page(:controller => "/images", :action => :thumbnail,   :id => image.id, :format => 'jpg')
    expire_page(:controller => "/images", :action => :header,   :id => image.id, :format => 'jpg')
    expire_page(:controller => "/images", :action => :big_header,   :id => image.id, :format => 'jpg')
    expire_page(:controller => "/images", :action => :full, :id => image.id, :format => 'jpg')
    expire_page(:controller => "/images", :action => :sidebox,   :id => image.id, :format => 'jpg')
    expire_page(:controller => "/images", :action => :content_box_header,   :id => image.id, :format => 'jpg')
  end
end
