# frozen_string_literal: true

class Article < ApplicationRecord
  validates :title, presence: true
  validates :content, presence: true
  validates :slug, presence: true, uniqueness: true

  has_many :comments, dependent: :destroy

  belongs_to :user

  scope :recent, -> { order(created_at: :desc) }
end
