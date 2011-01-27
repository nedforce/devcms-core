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
