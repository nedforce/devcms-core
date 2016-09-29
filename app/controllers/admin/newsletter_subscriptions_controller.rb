# This administrative controller is used to manage the website newsletter subscriptions. It is
# set up to communicate with ExtJS components using XML.
class Admin::NewsletterSubscriptionsController < Admin::AdminController
  # Require users to have at least one of the roles +admin+ or +final_editor+.
  require_role ['admin', 'final_editor'], any_node: true

  before_action :set_paging,  except: :destroy
  before_action :set_sorting, except: :destroy

  skip_before_action :set_actions
  skip_before_action :find_node

  layout false

  # * GET /newsletter_subscriptions/1
  # * GET /newsletter_subscriptions/1.xml
  #
  # Delegated to custom list action that accepts any HTTP verb so that ExtJS may page there.
  def show
    list
  end

  # * GET /newsletter_subscriptions/list/1
  # * GET /newsletter_subscriptions/list/1.xml
  #
  # ExtJS may also POST here while paging.
  def list
    @active_page = :sitemap

    @newsletter_archive = NewsletterArchive.find(params[:id])
    @users              = @newsletter_archive.users.order("#{@sort_field} #{@sort_direction}").page(@current_page).per(@page_limit)
    @user_count         = @newsletter_archive.users.count

    respond_to do |format|
      format.html { render :action => :list }
      format.xml  { render :action => :list, :layout => false }
    end
  end

  # This method is used to unsubscribe a user from a newsletter archive
  # * DELETE /admin/newsletter_subscriptions/1/users/2.xml
  def destroy
    @newsletter_archive = NewsletterArchive.find(params[:newsletter_subscription_id])
    @user               = User.find(params[:id])

    respond_to do |format|
      if @newsletter_archive.users.delete(@user)
        format.any { head :ok }
      else
        format.any { render :status => :not_found }
      end
    end
  end

  protected

  # Finds sorting parameters.
  def set_sorting
    if extjs_sorting?
      @sort_direction = (params[:dir] == 'ASC' ? 'ASC' : 'DESC')

      # Find out which (related) table and which column to sort on.
      first, *last = params[:sort].split('_')
      last = last.join('_') if last.is_a?(Array) # join again for columns like email_address
      @sort_field = (last.size > 0 ? "#{first.pluralize}.#{last}" : first)

      # Do not quote_column_name, because PostgreSQL will fail
      # and we already added quotes in the line above.
      # @sort_field = ActiveRecord::Base.connection.quote_column_name(@sort_field)
    else
      @sort_field = 'users.login'
    end
    @sort_field = "UPPER(#{@sort_field})" unless @sort_field =~ /id/
  end
end
