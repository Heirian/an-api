# frozen_string_literal: true

class ApplicationController < ActionController::API
  AuthorizationError = Class.new(StandardError)
  rescue_from UserAuthenticator::Oauth::AuthenticationError,
              with: :authenticator_oauth_error
  rescue_from UserAuthenticator::Standard::AuthenticationError,
              with: :authenticator_standard_error
  rescue_from AuthorizationError, with: :authorization_error

  before_action :authorize

  private

  def access_token
    @access_token ||= AccessToken.find_by(token: provided_token)
  end

  def authorize
    raise AuthorizationError unless current_user
  end

  def authenticator_oauth_error
    error = {
      'status' => '401',
      'source' => { 'pointer' => '/code' },
      'title' => 'Authentication code is invalid',
      'detail' => 'You must provide valid code in ' \
                  'order to exhange it for token.'
    }
    render json: { errors: [error] }, status: 401
  end

  def authenticator_standard_error
    error = {
      'status' => '401',
      'source' => { 'pointer' => '/data/attributes/password' },
      'title' => 'Invalid login or password',
      'detail' => 'You must provide valid credentials in order ' \
                  'to exchange them for token.'
    }
    render json: { errors: [error] }, status: 401
  end

  def authorization_error
    error = {
      'status' => '403',
      'source' => { 'pointer' => '/headers/authorization' },
      'title' => 'Not authorized',
      'detail' => 'You have not right to access this resource.'
    }
    render json: { errors: [error] }, status: 403
  end

  def current_user
    @current_user ||= access_token&.user
  end

  def provided_token
    request.authorization&.gsub(/\ABearer\s/, '')
  end
end
