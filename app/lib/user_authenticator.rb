# frozen_string_literal: true

class UserAuthenticator
  AuthenticationError = Class.new(StandardError)

  attr_reader :user, :access_token

  def initialize(code)
    @code = code
  end

  def perfom
    raise AuthenticationError if code.blank? || token.try(:error).present?

    prepare_user
    @access_token = user.access_token.presence || user.create_access_token
  end

  private

  attr_reader :code

  def client
    @client ||= Octokit::Client.new(
      client_id: ENV['GITHUB_CLIENT_ID'],
      client_secret: ENV['GITHUB_CLIENT_SECRET']
    )
  end

  def create_user
    User.create!(user_data.merge(provider: 'github'))
  end

  def find_user
    User.find_by(login: user_data[:login])
  end

  def prepare_user
    @user = find_user.presence || create_user
  end

  def token
    @token ||= client.exchange_code_for_token(code)
  end

  def user_data
    @user_data ||= Octokit::Client.new(
      access_token: token
    ).user.to_h.slice(:login, :avatar_url, :url, :name)
  end
end
