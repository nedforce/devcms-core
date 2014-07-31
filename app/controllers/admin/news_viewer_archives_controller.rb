class Admin::NewsViewerArchivesController < Admin::AdminController
  skip_before_filter    :find_node

  prepend_before_filter :find_news_viewer_and_node

  layout false

  require_role ['admin', 'final_editor']

  def create
    @news_viewer_archive = @news_viewer.news_viewer_archives.find_or_initialize_by_news_archive_id(NewsArchive.find(params[:news_archive_id]).id)

    respond_to do |format|
      if @news_viewer_archive.save
        format.xml { render :nothing => true, :status => :created }
      else
        format.xml { render :nothing => true, :status => :unprocessable_entity }
      end
    end
  end

  def delete_news_archive
    @news_archive = @news_viewer.news_viewer_archives.first(:conditions => { :news_archive_id => params[:news_archive_id] })

    respond_to do |format|
      if @news_archive.nil? or @news_archive.destroy
        format.xml { head :ok }
      else
        format.xml { render :nothing => true, :status => :unprocessable_entity }
      end
    end
  end

private

  def find_news_viewer_and_node
    @news_viewer = NewsViewer.find(params[:news_viewer_id])
    @node = @news_viewer.node
  end
end
