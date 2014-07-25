# This +RESTful+ controller is used to orchestrate and control the flow of
# the application relating to +NewsletterArchive+ objects.
class Admin::NewsletterArchivesController < Admin::AdminController

  acts_as_archive_controller :newsletter_archive

  before_filter :find_newsletter_editions, :only => :show
  
  skip_before_filter :find_node, :only => :index

  skip_before_filter :set_cache_buster, :only => [:index, :show]

  require_role ['admin', 'final_editor'], :except => [:index, :show]

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

  def subscription_emails
    @newsletter = NewsletterArchive.find(params[:id])
    @subscriber_users = @newsletter.users

    send_data @subscriber_users.map(&:email_address).join(', '), :filename => 'subscription_emails.txt'
  end

  def show
    @actions << { :url => { :action => :subscription_emails }, :text => I18n.t('newsletters.subscription_emails'), :method => :get, :ajax => false }

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
    @newsletter_editions = @newsletter_archive.newsletter_editions.accessible.all(:conditions => ['published <> ?', 'unpublished'], :page => { :size => 25, :current => 1 })
    @newsletter_editions_for_table  = @newsletter_editions.to_a
    @latest_newsletter_editions     = @newsletter_editions_for_table[0..5]
    @newsletter_editions_for_table -= @latest_newsletter_editions
  end
end
