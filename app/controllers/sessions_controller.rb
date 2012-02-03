# This controller implements most of the authentication and session
# maintenance functionality of the application. It does this in a +RESTful+ way:
# sessions are treated as resources. Thus, the +new+ action renders a login
# form, the +create+ action authenticates and (if successful) logs the user in,
# and the +destroy+ action logs the user out.

class SessionsController < ApplicationController

  # Makes sure that users that are already logged in
  # can't request the login form, or login again.
  before_filter :redirect_logged_in_users, :only => [ :new, :create ]

  # SSL encryption is required for the +new+ and +create+ actions.
  ssl_required :new, :create

  # * GET /session/new
  def new
  end

  # * POST /session
  def create
    @user = User.authenticate(params[:login], params[:password])
    self.current_user = @user if @user && @user.verified?

    if logged_in?
      if params[:remember_me] == '1'
        self.current_user.remember_me unless current_user.remember_token?
        cookies[:auth_token] = { :value => self.current_user.remember_token, :expires => self.current_user.remember_token_expires_at }
      end

      flash[:notice] = "#{I18n.t('sessions.logged_in_as')} '#{self.current_user.login}'."
      redirect_back_or_default(profile_path, false)
    elsif @user && !@user.verified?
      flash.now[:notice] = I18n.t('sessions.not_yet_verified') + ' ' + I18n.t('sessions.no_email?') + " <a href = \"#{send_verification_email_user_path(@user)}\">#{I18n.t('sessions.request_new_code')}</a>"
      render :action => 'new', :status => :unprocessable_entity
    else
      flash.now[:warning] = I18n.t('sessions.user_or_password_error')
      render :action => 'new', :status => :unprocessable_entity
    end
  end

  # * DELETE /session
  def destroy
    if logged_in?
      self.current_user.forget_me
      self.current_user = nil
      cookies.delete :auth_token
      if Settler[:after_logout_path].present?
        redirect_to Settler[:after_logout_path]
      else
        flash[:notice] = I18n.t('sessions.logged_out')
        redirect_to root_path
      end
    else
      flash[:warning] = I18n.t('sessions.cant_log_out')
      redirect_back_or_default(root_path, false)
    end
  end

  protected

  # Redirects users that are already logged in.
  def redirect_logged_in_users
    if logged_in?
      flash.keep
      flash[:notice] = "#{I18n.t('sessions.already_logged_in')} '#{self.current_user.login}'." unless flash[:notice]
      redirect_to root_path
    end
  end

  def set_page_title
    @page_title = I18n.t('sessions.log_in')
  end
end
