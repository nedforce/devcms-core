# This +RESTful+ controller is used to orchestrate and control the flow of
# the application relating to +NewsletterArchive+ objects.
class Admin::NewsletterArchivesController < Admin::AdminController

  acts_as_archive_controller :newsletter_archive

  before_filter :find_newsletter_editions, :only => :show
  
  skip_before_filter :find_node, :only => :index

  skip_before_filter :set_cache_buster, :only => [ :index, :show ]

  require_role [ 'admin', 'final_editor' ], :except => [ :index, :show ]

  def index
    respond_to do |format|
      format.csv do
        require 'csv'
        @newsletters = NewsletterArchive.all
        render :action => :index, :layout => false
      end
      # Default to index method from ActsAsArchiveController module
      format.any { super }
    end
  end

  def show
    respond_to do |format|
      format.csv do
        require 'csv'
        @newsletter = NewsletterArchive.find(params[:id])
        render :action => :show, :layout => false
      end
      # Default to index method from ActsAsArchiveController module
      format.any { super }
    end
  end

protected

  def find_newsletter_editions
    @newsletter_editions = @newsletter_archive.newsletter_editions.accessible.where([ 'published <> ?', 'unpublished' ]).page(1).per(25)
    @newsletter_editions_for_table  = @newsletter_editions.to_a
    @latest_newsletter_editions     = @newsletter_editions_for_table[0..5]
    @newsletter_editions_for_table -= @latest_newsletter_editions
  end
end
