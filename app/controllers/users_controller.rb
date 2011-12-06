# This +RESTful+ controller is used to orchestrate and control the flow of 
# the application relating to +User+ objects.

class UsersController < ApplicationController

  skip_before_filter :find_node  
    
  # SSL encryption is required for these actions:
  ssl_required :new, :create, :verification, :edit, :update, :confirm_destroy, :destroy
  
  # SSL encryption is optional for the #show action.
  ssl_allowed :show

  before_filter :verify_invitation_code, :only => [ :new, :create ]
  
  before_filter :find_user, :only => [ :send_verification_email, :verification ]
  
  # Only allow updates and views for the owner of a user record.
  before_filter :login_required, :set_user, :only => [ :edit, :update, :show, :profile, :destroy, :confirm_destroy ]
  before_filter :set_user,                  :only => [ :edit, :update, :show,           :destroy, :confirm_destroy ]

  before_filter :get_newsletters, :only => [ :new, :create, :show, :profile ]
  before_filter :get_interests,   :only => [ :new, :create, :show, :profile ]

  # Shows the registration form.
  #
  # * GET /users/new
  # * GET /users/new.xml
  def new
    @user = User.new(:email_address => params[:invitation_email])
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # Registers a new user. Does not register a user if the "username" attribute
  # was also set by the form to ward off any spambots.
  #
  # * POST /users
  # * POST /users.xml
  def create
    if params[:user][:username].present?
      flash[:error] = I18n.t('users.try_again')
      redirect_to new_user_path
    else
      cookies.delete :auth_token
      @user = User.new(params[:user])

      respond_to do |format|
        if @user.save
          format.html do
            if Settler[:after_signup_path].present?
              redirect_to Settler[:after_signup_path]
            else
              flash[:notice] = I18n.t('users.welcome')
              redirect_to login_path
            end
          end
          format.xml  { render :xml => @user.to_xml, :status => :created, :location => @user }
        else
          format.html { render :action => 'new' }
          format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
        end
      end
    end
  end
  
  def profile
    @user = current_user
    render :action => 'show'
  end

  # Shows user profile page.
  #
  # * GET /users/:id
  def show
  end

  # Shows edit user details form.
  #
  # * GET /users/:id/edit
  def edit
  end

  # Updates a users details.
  #
  # * PUT /users/:id
  # * PUT /users/:id.xml
  def update
    if params[:update_newsletters_and_interests]
      params[:user] ||= {}
      params[:user][:newsletter_archive_ids] ||= []
      params[:user][:interest_ids] ||= []
    end

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html do
          flash[:notice] = I18n.t('users.update_successful')
          redirect_to @user
        end
        format.xml  { head :ok }
      else
        format.html { render :action => 'edit' }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # Shows a user deletion confirmation form
  #
  # * GET /users/:id/confirm_destroy
  def confirm_destroy
  end

  # Deletes an user.
  #
  # * DELETE /users/:id
  def destroy
    respond_to do |format|
      format.html do
        if @user == User.authenticate(@user.login, params[:user][:password])
          @user.destroy
          flash[:notice] = I18n.t('users.deleted')
          redirect_to root_path
        else
          flash[:notice] = I18n.t('users.wrong_password')
          redirect_to confirm_destroy_user_path(@user)
        end
      end
    end
  end

  # Verifies a user if the given verification code matches the user's code.
  #
  # * GET /users/:login/verification?code=XXXXXX
  # * GET /users/:login/verification.xml?code=XXXXXX
  # 
  # <b>parameters:</b>
  # * code - String. The user's verification code.
  def verification
    respond_to do |format|
      if @user.verify_with(params[:code])
        format.html do
          flash[:notice] = I18n.t('users.successfully_verified')
          redirect_to login_path
        end
        format.xml { head :ok }
      else
        @page_title = I18n.t('users.verification_failed')
        format.html { render :action => 'verification_failed' }
        format.xml  { render :xml => { :error => I18n.t('users.verification_failed') }.to_xml, :status => :unprocessable_entity }
      end
    end
  end

  # Generates a new verification code and sends it to the user's email address.
  # 
  # * GET /users/1/send_verification_email
  def send_verification_email
    unless @user.verified?
      @user.reset_verification_code
      UserMailer.deliver_verification_email(@user)      
      flash[:notice]  = I18n.t('users.sent_verification_email')
    else
      flash[:warning] = I18n.t('users.already_verified')
    end

    respond_to do |format|
      format.html { redirect_to login_path }
    end
  end

  # Renders the request password view
  #
  # * GET  /users/request_password
  def request_password
    @page_title = I18n.t('users.request_password')
  end

  # Resets a user's password and sends the new password by email.
  # 
  # * GET /users/send_password?login_email=arthur
  # * GET /users/send_password?login_email=arthur@nedforce.nl
  #
  # <b>parameters</b>
  # * login_email - String. The login name or email address of the user that is requesting his password.
  def send_password
    @user = User.find_by_login(params[:login_email]) || User.find_by_email_address(params[:login_email])
    respond_to do |format|
      if @user  
        pw = @user.reset_password
        UserMailer.deliver_password_reminder(@user, pw, :host => request.host)
        format.html do
          flash[:notice] = "#{I18n.t('users.password_sent_to')} #{@user.email_address}"
          redirect_to login_path
        end
      else
        format.html do
          flash[:warning] = I18n.t('users.couldnt_find_user')
          redirect_to request_password_users_path
        end
      end
    end
  end

protected

  # Finds the requested user and saves it to the <tt>@user</tt> instance variable.
  def find_user
    @user = User.find_by_login(params[:id])
    raise ActiveRecord::RecordNotFound if @user.nil?
  end

  def set_user
    @user = User.find_by_id_and_login(current_user.id, params[:id])
    raise ActiveRecord::RecordNotFound if @user.nil?
  end

  def get_newsletters
    @newsletter_archives = NewsletterArchive.find_accessible(:all, :order => 'title', :for => current_user)
  end

  def get_interests
    @interests = Interest.all(:order => 'title')
  end

  def set_page_title
    case action_name.to_s
      when 'new', 'create'
        @page_title = I18n.t('users.register')
      when 'show', 'edit', 'profile'
        @page_title = I18n.t('users.profile')
    end
  end

  def verify_invitation_code
    @invitation_email = params[:invitation_email]
    @invitation_code  = params[:invitation_code]
    unless User.verify_invitation_code(@invitation_email, @invitation_code) || (@invitation_code.blank? && @invitation_email.blank? && !Settler[:user_invite_only])
      flash[:warning] = I18n.t('users.invalid_invitation_code_or_invitation_email')
      redirect_to root_path
    end
  end
end
