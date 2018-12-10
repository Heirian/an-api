# frozen_string_literal: true

class UserAuthenticator
  AuthenticationError = Class.new(StandardError)

  attr_reader :authenticator

  def initialize(code: nil, login: nil, password: nil)
    @authenticator = if code.present?
                       Oauth.new(code: code)
                     else
                       Standard.new(login: login, password: password)
                     end
  end

  def perfom
    authenticator.perfom
  end

  def user
    authenticator.user
  end

  def access_token
    user.access_token.presence || user.create_access_token
  end
end
