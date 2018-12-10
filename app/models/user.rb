# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password validations: false
  validates :login, presence: true, uniqueness: true
  validates :provider, presence: true

  has_many :articles, dependent: :destroy
  has_many :comments, dependent: :destroy

  has_one :access_token, dependent: :destroy
end
