# frozen_string_literal: true

class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :login, :avatar_url, :url
end
