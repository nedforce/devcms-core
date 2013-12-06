# This controller implements most of the authentication and session
# maintenance functionality of the application. It does this in a +RESTful+ way:
# sessions are treated as resources. Thus, the +new+ action renders a login
# form, the +create+ action authenticates and (if successful) logs the user in,
# and the +destroy+ action logs the user out.

class SessionsController < ApplicationController

  before_filter :confirm_destroy, :only => :destroy, :unless => lambda{ request.delete? }

  # Makes sure that users that are already logged in
  # can't request the login form, or login again.
  before_filter :redirect_logged_in_users, :only => [ :new, :create ]

  # SSL encryption is required for the +new+ and +create+ actions.
  ssl_required :new, :create

  # * GET /session/new
  def new
    respond_to do |format|
      format.html # new.html.haml
    end
  end

  # * POST /session
  def create
    trusted_user = Settler[:whitelisted_ips].present? && Settler[:whitelisted_ips].split(',').include?(request.remote_ip)

    if !trusted_user && login_enabled_at = LoginAttempt.is_ip_blocked?(request.remote_ip)
      flash[:warning] = I18n.t('sessions.logins_disabled') + ' ' + I18n.l(login_enabled_at, :format => :long) + '.'
      render_login_form
    elsif !trusted_user && LoginAttempt.last_attempt_was_not_ten_seconds_ago(request.remote_ip)
      flash[:warning] = I18n.t('sessions.logins_throttled')
      render_login_form
    else
      @user = User.authenticate(params[:login], params[:password])
      self.current_user = @user if @user && @user.verified? && !@user.blocked?
      LoginAttempt.create! :ip => request.remote_ip, :user_login => params[:login], :success => !@user.nil?

      if logged_in?
        if params[:remember_me] == '1'
          self.current_user.remember_me(request.ip) unless current_user.remember_token?
          cookies[:auth_token] = { :value => self.current_user.remember_token, :expires => self.current_user.remember_token_expires_at }
        end

        flash[:notice] = "#{I18n.t('sessions.logged_in_as')} '#{self.current_user.login}'."
        redirect_back_or_default(profile_path, false)
      elsif @user && !@user.verified?
        flash.now[:notice] = (I18n.t('sessions.not_yet_verified') + ' ' + I18n.t('sessions.no_email?') + " <a href = \"#{send_verification_email_user_path(@user)}\">#{I18n.t('sessions.request_new_code')}</a>").html_safe
        render_login_form
      elsif @user && @user.blocked?
        flash[:warning] = I18n.t('sessions.account_blocked')
        render_login_form
      else
        flash.now[:warning] = I18n.t('sessions.user_or_password_error')
        render_login_form
      end
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

  def render_login_form
    render :action => 'new', :status => :unprocessable_entity
  end
end
