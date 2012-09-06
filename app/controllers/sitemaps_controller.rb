class SitemapsController < ApplicationController
  skip_before_filter :find_node
  
  before_filter :set_node_to_root, :only => :changes

  # Shows the sitemap.
  #
  # * GET /sitemap
  def show  
    respond_to do |format|
      format.html # index.html.erb
    end  
  end
  
  # Shows the changes since params[:interval] in seconds
  #
  # * GET /sitemap/changes
  def changes
    respond_to do |format|
      format.xml do
        raise ::AbstractController::ActionNotFound if params[:interval].blank?
        @changes = Node.all_including_deleted(:conditions => ["updated_at > ?", Time.now - params[:interval].to_i], :order => "updated_at DESC" )
      end
      format.any(:rss, :atom) do
        @nodes = @node.last_changes(:all, { :limit => 25 })
        render :template => '/shared/changes', :layout => false
      end
    end
  end
  
protected

  def set_node_to_root
    @node = current_site
  end
  
  def set_rss_feed_url
    @rss_feed_url = changes_sitemap_url(:format => 'atom')
  end

  def set_page_title
    @page_title = I18n.t('sitemaps.sitemap')
  end
end
