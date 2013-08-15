# This +RESTful+ controller is used to orchestrate and control the flow of 
# the application relating to +NewsletterArchive+ objects.
class NewsletterArchivesController < ApplicationController

  # All actions needs a +NewsletterArchive+ object to work with.  
  before_filter :find_newsletter_archive, :only => [ :show, :subscribe, :unsubscribe ]

  # Require user to be logged in for the +subscribe+ and +unsubscribe+ actions.
  before_filter :login_required, :only => [ :subscribe, :unsubscribe ]

  # Enable unsubscrubing using regular hyperlinks and <tt>:method => :delete</tt>.
  # See ApplicationController for more details.
  before_filter :confirm_destroy, :only => :unsubscribe, :unless => lambda{ request.delete? } 

  # * GET /newsletter_archives/:id
  # * GET /newsletter_archives/:id.xml
  def show
    @newsletter_editions = @newsletter_archive.newsletter_editions.accessible.where([ 'published <> ?', 'unpublished' ]).page(params[:page]).per(25)

    first_page = !params[:page] || params[:page]==1
    @latest_newsletter_editions    = []
    @newsletter_editions_for_table = @newsletter_editions.to_a 
    if first_page
      @latest_newsletter_editions     = @newsletter_editions_for_table[0..5]
      @newsletter_editions_for_table -= @latest_newsletter_editions 
    end

    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @newsletter_archive }
    end
  end

  # * POST /newsletter_archives/:id/subscribe
  # * POST /newsletter_archives/:id/subscribe.xml
  def subscribe
    respond_to do |format|
      unless @newsletter_archive.has_subscription_for?(current_user)
        @newsletter_archive.users << current_user
        format.html do 
          if request.xhr?
            render :partial => '/newsletter_archives/content_box_content', :locals => { :node => @node }
          else
            flash[:notice] = I18n.t('newsletters.subscribe_successfull')
            redirect_to @newsletter_archive
          end
        end
        format.xml { head :ok }
      else
        format.html do
          if request.xhr?          
            render :partial => '/newsletter_archives/content_box_content', :locals => { :node => @node }
          else
            flash[:warning] = I18n.t('newsletters.subscribe_unsuccessfull')
            redirect_to @newsletter_archive
          end
        end
        format.xml { render :xml => @newsletter_archive.errors, :status => :unprocessable_entity }
      end
    end
  end

  # * DELETE /newsletter_archives/:id/unsubscribe
  # * DELETE /newsletter_archives/:id/unsubscribe.xml
  def unsubscribe
    respond_to do |format|
      if @newsletter_archive.has_subscription_for?(current_user)
        @newsletter_archive.users.delete(current_user)
        format.html do 
          if request.xhr?
            render :partial => '/newsletter_archives/content_box_content', :locals => { :node => @node }
          else
            flash[:notice] = I18n.t('newsletters.unsubscribe_successfull')
            redirect_back_or_default(@newsletter_archive)
          end
        end
        format.xml { head :ok }
      else
        format.html do 
          if request.xhr?
            render :partial => '/newsletter_archives/content_box_content', :locals => { :node => @node }
          else
            flash[:warning] = I18n.t('newsletters.unsubscribe_unsuccessfull')
            redirect_back_or_default(@newsletter_archive)
          end
        end
        format.xml { render :xml => @newsletter_archive.errors, :status => :unprocessable_entity }
      end
    end
  end

protected

  # Finds the +NewsletterArchive+ object corresponding to the passed in +id+ parameter.
  def find_newsletter_archive
    @newsletter_archive = @node.content
  end

end
