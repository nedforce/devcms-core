module DevcmsCore
  module AuthenticatedTestHelper
    def login_as(user)
      auth_token = nil
      auth_token = (user.is_a?(User) ? user.auth_token : users(user).auth_token) if user
      cookies[:auth_token] = { value: auth_token }
    end

    def authorize_as(user)
      @request.env['HTTP_AUTHORIZATION'] = user ? ActionController::HttpAuthentication::Basic.encode_credentials(users(user).login, 'test') : nil
    end
  end
end
