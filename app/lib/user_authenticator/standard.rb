# frozen_string_literal: true

class UserAuthenticator::Standard < UserAuthenticator
  AuthenticationError = Class.new(StandardError)

  attr_reader :user

  def initialize(login: nil, password: nil)
    @login = login
    @password = password
  end

  def perfom
    raise AuthenticationError if login.blank? || password.blank?
    raise AuthenticationError unless (u = User.find_by(login: login))
    raise AuthenticationError unless u.authenticate(password)

    @user = u
  end

  private

  attr_reader :login, :password
end
