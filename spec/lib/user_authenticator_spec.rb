# frozen_string_literal: true

require 'rails_helper'

describe UserAuthenticator do
  let(:user) { create(:user, login: 'jsmith', password: 'secret') }

  shared_examples_for 'authenticator' do
    it 'should create and set user\'s access token' do
      expect(authenticator.authenticator).to receive(:perfom).and_return(true)
      expect(authenticator.authenticator).to receive(:user).at_least(:once)
                                                           .and_return(user)
      expect(authenticator.perfom).to eq(true)
      expect { authenticator.access_token }.to(
        change { AccessToken.count }.by(1)
      )
      expect(authenticator.access_token).to be_present
    end
  end

  context 'when initialized with code' do
    let(:authenticator) { described_class.new(code: 'sample') }
    let(:authenticator_class) { UserAuthenticator::Oauth }

    describe '#initialize' do
      it 'should initialize proper authenticator' do
        expect(authenticator_class).to receive(:new).with(code: 'sample')
        authenticator
      end
    end

    it_behaves_like 'authenticator'
  end

  context 'when initialized with login & password' do
    let(:authenticator) do
      described_class.new(login: 'jsmith', password: 'secret')
    end
    let(:authenticator_class) { UserAuthenticator::Standard }

    describe '#initialize' do
      it 'should initialize proper authenticator' do
        expect(authenticator_class).to receive(:new).with(
          login: 'jsmith', password: 'secret'
        )
        authenticator
      end
    end

    it_behaves_like 'authenticator'
  end
end
