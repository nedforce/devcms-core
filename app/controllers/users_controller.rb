# This +RESTful+ controller is used to orchestrate and control the flow of
# the application relating to +User+ objects.
class UsersController < ApplicationController
  skip_before_filter :find_node

  # SSL encryption is required for these actions:
  ssl_required :new, :create, :verification, :edit, :update, :confirm_destroy, :destroy

  before_filter :verify_invitation_code, only: [:new, :create]

  before_filter :find_user, only: [:send_verification_email, :verification]

  # Only allow updates and views for the owner of a user record.
  before_filter :login_required, :set_user, only: [:edit, :update, :show, :profile, :destroy, :confirm_destroy]
  before_filter :set_user,                  only: [:edit, :update, :show,           :destroy, :confirm_destroy]

  before_filter :get_newsletters, only: [:new, :create, :show, :profile]
  before_filter :get_interests,   only: [:new, :create, :show, :profile]

  # Shows the registration form.
  #
  # * GET /users/new
  # * GET /users/new.xml
  def new
    suplied_email = params[:invitation_email] || params[:email_address]
    @user = User.new(email_address: suplied_email)
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @user }
    end
  end

  # Registers a new user. Does not register a user if the "username" attribute
  # was also set by the form to ward off any spambots.
  #
  # * POST /users
  # * POST /users.xml
  def create
    if params[:user].present? && params[:user][:username].present?
      flash[:error] = I18n.t('users.try_again')
      redirect_to new_user_path
    else
      cookies.delete :auth_token
      @user = User.new(permitted_attributes)

      respond_to do |format|
        # user.save will fail if the e-mail has already been used, but because
        # we do not want to leak this information, it will still show a success
        # page. An e-mail notice will be send with the before_create statement
        # in the user model.
        if @user.save || @user.valid?
          format.html do
            if Settler[:after_signup_path].present?
              redirect_to Settler[:after_signup_path]
            else
              flash[:notice] = I18n.t('users.welcome')
              redirect_to login_path
            end
          end
          format.xml { render xml: @user.to_xml, status: :created, location: @user }
        else
          # Clear the password and password confirmation fields.
          @user.password = @user.password_confirmation = nil
          format.html { render action: 'new',     status: :unprocessable_entity }
          format.xml  { render xml: @user.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  def profile
    @user = current_user
    render action: 'show'
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
          redirect_to user_path(@user)
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
  # * GET /users/:id/confirm_destroy
  def confirm_destroy
  end

  # Deletes a user.
  #
  # * DELETE /users/:id
  def destroy
    respond_to do |format|
      format.html do
        if params[:user].present? && @user == User.authenticate(@user.login, params[:user][:password])
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
        format.html { render action: 'verification_failed' }
        format.xml  { render xml: { error: I18n.t('users.verification_failed') }.to_xml, status: :unprocessable_entity }
      end
    end
  end

  # Generates a new verification code and sends it to the user's email address.
  #
  # * GET /users/:id/send_verification_email
  def send_verification_email
    if @user.verified?
      flash[:warning] = I18n.t('users.already_verified')
    else
      @user.reset_verification_code
      UserMailer.verification_email(@user).deliver_now
      flash[:notice] = I18n.t('users.sent_verification_email')
    end

    respond_to do |format|
      format.html { redirect_to login_path }
    end
  end

  protected

  def permitted_attributes
    params.fetch(:user, {}).permit(:login, :first_name, :surname, :sex, :email_address, :password, :password_confirmation, newsletter_archive_ids: [], interest_ids: [])
  end

  # Finds the requested user and saves it to the <tt>@user</tt> instance
  # variable.
  def find_user
    @user = User.find_by_login!(params[:id])
  end

  def set_user
    @user = User.find_by_id_and_login!(current_user.id, params[:id])
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
