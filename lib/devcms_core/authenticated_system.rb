module DevcmsCore
  module AuthenticatedSystem
    protected

      # Returns true or false if the user is logged in.
      # Preloads @current_user with the user model if they're logged in.
      def logged_in?
        !!current_user
      end

      # Future calls avoid the database because nil is not equal to false.
      def current_user
        @current_user ||= User.find_by_auth_token(auth_cookies[DevcmsCore.config.auth_token_cookie]) if auth_cookies[DevcmsCore.config.auth_token_cookie]
      end

      # Check if the user is authorized
      #
      # Override this method in your controllers if you want to restrict access
      # to only a few actions or if you want to check if the user
      # has the correct rights.
      #
      # Example:
      #
      #  # only allow nonbobs
      #  def authorized?
      #    current_user.login != 'bob'
      #  end
      def authorized?
        logged_in?
      end

      # Filter method to enforce a login requirement.
      #
      # To require logins for all actions, use this in your controllers:
      #
      #   before_filter :login_required
      #
      # To require logins for specific actions, use this in your controllers:
      #
      #   before_filter :login_required, only: [:edit, :update]
      #
      # To skip this in a subclassed controller:
      #
      #   skip_before_filter :login_required
      #
      def login_required
        authorized? || access_denied
      end

      # Redirect as appropriate when an access request fails.
      #
      # The default action is to redirect to the login screen.
      #
      # Override this method in your controllers if you want to have special
      # behavior in case the user is not authorized
      # to access the requested action.  For example, a popup window might
      # simply close itself.
      def access_denied
        respond_to do |format|
          format.html do
            store_location
            flash[:warning] = I18n.t('authenticated_system.not_authenticated')
            redirect_to new_session_path
          end
          format.js do
            #store_location
            render :update do |page|
              page.redirect_to login_path
            end
          end
          #format.any do
          #  request_http_basic_authentication 'Web Password'
          #end
        end
      end

      # Store the URI of the current request in the session.
      #
      # We can return to this location by calling #redirect_back_or_default.
      def store_location
        session[:return_to] = fullpath if !request.xhr? && request.method == 'GET'
      end

      # First attempts to redirect to the location set by <tt>params[:return_to]</tt> then to 
      # the location stored on the last <tt>store_location</tt> call.
      # If no location is set in the params or session, a <tt>redirect_to :back</tt> is attempted.
      # If that fails, a redirection to the passed <tt>default</tt> is issued.
      # In the case of an XHR, a page reload is issued.
      # If <tt>use_redirect_to_back</tt> is set to false, no <tt>redirect_to :back</tt> is attempted.
      def redirect_back_or_default(default = root_path, use_redirect_to_back = true)
        respond_to do |format|
          format.html do
            if return_to = params[:return_to] || session[:return_to]
              session[:return_to] = nil
              redirect_to return_to
            elsif use_redirect_to_back
              redirect_to :back rescue redirect_to default
            else
              redirect_to default
            end
          end
          format.js do
            render :update do |page|
              if return_to = params[:return_to] || session[:return_to]
                session[:return_to] = nil
                redirect_to return_to
              else
                page << "window.location.reload(true)"
              end
            end
          end
        end
      end

      # Inclusion hook to make #current_user and #logged_in?
      # available as ActionView helper methods.
      def self.included(base)
        base.send :helper_method, :current_user, :logged_in?
      end

      def ip_violation(ip)
        if ip != request.remote_ip
          mismatched_user = User.find_by_auth_token(cookies[:auth_token])

          Rails.logger.info "#{Time.zone.now} AUTHENTICATION IP MISMATCH: For user (#{mismatched_user.try(:login)}). " +
            "IP should be (#{ip}), IP was (#{request.remote_ip})"
          true
        else
          false
        end
      end

      def auth_cookies
        DevcmsCore.config.signed_cookies ? cookies.signed : cookies
      end

      def set_auth_token user, options = {}
        user.generate_token!(:auth_token) if user.auth_token.nil? || DevcmsCore.config.refresh_auth_token_after_sign_in
        cookie_data = DevcmsCore.config.cookie_options.merge(value: user.auth_token)
        cookie_data[:secure] = true if ssl_required?

        cookie_jar = auth_cookies
        cookie_jar = auth_cookies.permanent if options[:permanent]
        cookie_jar[DevcmsCore.config.auth_token_cookie] = cookie_data
      end
  end
end
