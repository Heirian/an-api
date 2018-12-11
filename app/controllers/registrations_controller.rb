# frozen_string_literal: true

class RegistrationsController < ApplicationController
  skip_before_action :authorize, only: %i[create]

  def create
    user = User.new(registration_params.merge(provider: 'standard'))
    if user.save
      render json: user, status: :created
    else
      render json: user, adapter: :json_api,
             serializer: ErrorSerializer,
             status: :unprocessable_entity
    end
  end

  private

  def registration_params
    params.require(:data)
          .require(:attributes)
          .permit(:login, :password) ||
      ActionController::Parameters.new
  end
end
