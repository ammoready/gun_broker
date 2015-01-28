module GunBroker
  class User

    def initialize(username, password)
      @username = username
      @password = password
    end

    def authenticate!
      response = GunBroker::API.post('/Users/AccessToken', { username: @username, password: @password })
      raise 'Not yet implemented.'
    end

  end
end
