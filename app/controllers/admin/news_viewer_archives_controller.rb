class Admin::NewsViewerArchivesController < Admin::AdminController
  skip_before_action :find_node

  prepend_before_action :find_news_viewer_and_node

  layout false

  require_role ['admin', 'final_editor']

  def create
    @news_viewer_archive = @news_viewer.news_viewer_archives.find_or_initialize_by(news_archive_id: NewsArchive.find(params[:news_archive_id]).id)

    respond_to do |format|
      if @news_viewer_archive.save
        format.xml { head :created }
      else
        format.xml { head :unprocessable_entity }
      end
    end
  end

  def delete_news_archive
    @news_archive = @news_viewer.news_viewer_archives.where(news_archive_id: params[:news_archive_id]).first

    respond_to do |format|
      if @news_archive.nil? or @news_archive.destroy
        format.xml { head :ok }
      else
        format.xml { head :unprocessable_entity }
      end
    end
  end

private

  def find_news_viewer_and_node
    @news_viewer = NewsViewer.find(params[:news_viewer_id])
    @node = @news_viewer.node
  end
end
