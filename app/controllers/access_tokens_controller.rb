# frozen_string_literal: true

class AccessTokensController < ApplicationController
  skip_before_action :authorize, only: :create

  def create
    authenticator = UserAuthenticator.new(params[:code])
    authenticator.perfom

    render json: authenticator.access_token, status: :created
  end

  def destroy
    access_token.destroy
  end
end
