module DevcmsCore
  module AuthenticatedTestHelper

    def login_as(user)
      user_id = nil      
      user_id = (user.is_a?(User) ? user.id : users(user).id) if user
      @request.session[:user_id] = user_id
    end

    def authorize_as(user)
      @request.env["HTTP_AUTHORIZATION"] = user ? ActionController::HttpAuthentication::Basic.encode_credentials(users(user).login, 'test') : nil
    end
  end
end