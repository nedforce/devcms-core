class PasswordRenewalsController < ApplicationController
  skip_before_filter :find_node
  skip_before_filter :check_password_renewal

  ssl_required :edit, :update

  before_filter :login_required, :set_user

  def edit
    respond_to do |format|
      format.html
    end
  end

  def update
    @user.require_password = true

    if @user.update_attributes(permitted_attributes)
      @user.generate_token!(:auth_token)
      set_auth_token(@user, permanent: !!session[:use_permanent_auth_token])
      flash[:notice] = I18n.t('sessions.logged_in_as', login: @user.login)
      redirect_back_or_default(profile_path, false)
    else
      render 'edit'
    end
  end

  protected

  def set_user
    @user = current_user
  end

  def permitted_attributes
    @permitted_attributes ||= params.fetch(:user, {}).permit(:password, :password_confirmation)
  end

end
