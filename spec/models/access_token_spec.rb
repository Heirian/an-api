require 'rails_helper'

RSpec.describe AccessToken, type: :model do
  describe '#validations' do
    it 'should have a valid factory' do
      expect(build(:access_token)).to be_valid
    end

    it 'should validate presence of attributes' do
      access_token = build(:access_token, token: nil, user: nil)
      expect(access_token).not_to be_valid
      expect(access_token.errors.messages[:token]).to include("can't be blank")
      expect(access_token.errors.messages[:user]).to include("can't be blank")
    end

    it 'should validate uniqueness of token' do
      access_token = create(:access_token)
      other_access_token = build(:access_token, token: access_token.token)
      expect(other_access_token).not_to be_valid
      other_access_token.token = 'new_login'
      expect(other_access_token).to be_valid
    end
  end

  describe '#new' do
    it 'should have a token present after initialize' do
      expect(AccessToken.new.token).to be_present
    end

    it 'should generate uniq token' do
      user = create(:user)
      expect { user.create_access_token }.to change { AccessToken.count }.by(1)
      expect(user.build_access_token).to be_valid
    end

    it 'should keep the same token' do
      user = create(:user)
      user.create_access_token
      access_token = user.access_token
      token = access_token.token
      reload_token = access_token.reload.token
      expect(token).to eq(reload_token)
    end
  end
end
