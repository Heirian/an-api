# frozen_string_literal: true

FactoryBot.define do
  factory :access_token do
    token { 'MyString' }
    user { create(:user) }
  end
end
