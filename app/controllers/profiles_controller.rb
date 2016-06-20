# This +RESTful+ controller is used to orchestrate and control the flow of
# the application relating to +User+ objects.
class ProfilesController < ApplicationController
  skip_before_filter :find_node

  # SSL encryption is required for these actions:
  ssl_required :show, :edit, :update, :confirm_destroy, :destroy

  before_filter :login_required, :set_user
  before_filter :get_newsletters, only: :show
  before_filter :get_interests,   only: :show

  def show
  end

  # Shows edit user details form.
  #
  # * GET /profile/edit
  def edit
  end

  # Updates a users details.
  #
  # * PUT /profile
  # * PUT /profile.xml
  def update
    if params[:update_newsletters_and_interests]
      params[:user] ||= {}
      params[:user][:newsletter_archive_ids] ||= []
      params[:user][:interest_ids] ||= []
    end

    @user.attributes = permitted_attributes

    respond_to do |format|
      # Password check when there's a email/password change
      if (@user.changed.include?('email_address') || params[:user][:password].present?) && !@user.authenticated?(params[:old_password])
        format.html do
          @user.errors.add :base, I18n.t('users.wrong_password')
          render action: 'edit', status: :unprocessable_entity
        end
        format.xml  { head :unprocessable_entity }
      elsif @user.save
        format.html do
          flash[:notice] = I18n.t('users.update_successful')
          redirect_to profile_path
        end
        format.xml  { head :ok }
      else
        format.html { render action: 'edit',    status: :unprocessable_entity }
        format.xml  { render xml: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # Shows a user deletion confirmation form
  #
  # * GET /profile/confirm_destroy
  def confirm_destroy
  end

  # Deletes a user.
  #
  # * DELETE /profile
  def destroy
    respond_to do |format|
      format.html do
        if params[:user].present? && @user == User.authenticate(@user.login, params[:user][:password])
          @user.destroy
          flash[:notice] = I18n.t('users.deleted')
          redirect_to root_path
        else
          flash[:notice] = I18n.t('users.wrong_password')
          redirect_to confirm_destroy_profile_path
        end
      end
    end
  end

  protected

  def permitted_attributes
    params.fetch(:user, {}).permit(:login, :first_name, :surname, :sex, :email_address, :password, :password_confirmation, newsletter_archive_ids: [], interest_ids: [])
  end

  def set_user
    @user = current_user
  end

  def get_newsletters
    @newsletter_archives = NewsletterArchive.accessible.to_a.select do |na|
      node = na.node
      !node.self_and_ancestors.sections.is_private.exists? || (current_user && current_user.role_assignments.where(node_id: node.self_and_ancestor_ids).exists?)
    end
  end

  def get_interests
    @interests = Interest.order(:title).to_a
  end

  def set_page_title
    @page_title = I18n.t('users.profile')
  end

end
