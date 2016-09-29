# This +RESTful+ controller is used to orchestrate and control the flow of
# the application relating to +User+ password resets.
class PasswordResetsController < ApplicationController
  skip_before_action :find_node

  ssl_required :new, :create, :edit, :update

  before_action :find_user_by_password_reset_token, only: [:edit, :update]

  def new
    respond_to do |format|
      format.html # new.html.haml
    end
  end

  def create
    @user = User.find_by_email_address(params[:login_email]) || User.find_by_login(params[:login_email])

    if @user
      @user.create_password_reset_token
      UserMailer.password_reset(@user, host: request.host).deliver_now
    elsif validate_email_address(params[:login_email])
      UserMailer.account_does_not_exist(params[:login_email], host: request.host).deliver_now
    end

    redirect_to login_path, notice: I18n.t('users.password_reset_sent')
  end

  def edit
    respond_to do |format|
      format.html # edit.html.haml
    end
  end

  def update
    @user.password_reset_token = nil # Kill reset when we succeed
    if @user.password_reset_expiration < Time.now
      redirect_to new_password_reset_path, notice: I18n.t('users.password_reset_expired')
    elsif @user.update_attributes(permitted_attributes)
      @user.generate_token!(:auth_token) if DevcmsCore.config.refresh_auth_token_after_password_reset
      redirect_to login_path, notice: I18n.t('users.password_reset_succesful')
    else
      render 'edit'
    end
  end

  protected

  def permitted_attributes
    params.fetch(:user, {}).permit(:password, :password_confirmation)
  end

  def find_user_by_password_reset_token
    @user = User.where(password_reset_token: params[:id]).first!
  end

  def validate_email_address(email_address)
    email_address =~ EmailValidator::REGEX
  end
end
