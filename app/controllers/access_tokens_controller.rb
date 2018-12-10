# frozen_string_literal: true

class AccessTokensController < ApplicationController
  skip_before_action :authorize, only: :create

  def create
    authenticator = UserAuthenticator.new(authorization_params)
    authenticator.perfom

    render json: authenticator.access_token, status: :created
  end

  def destroy
    access_token.destroy
  end

  private

  def authorization_params
    (standard_params || oauth_params).to_h.symbolize_keys
  end

  def standard_params
    params.dig(:data, :attributes)&.permit(:login, :password)
  end

  def oauth_params
    params.permit(:code)
  end
end
