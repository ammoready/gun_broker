module GunBroker
  class User

    attr_reader :username
    attr_reader :token

    def initialize(username, auth_options = {})
      @username = username
      @password = auth_options[:password] || auth_options['password']
      @token    = auth_options[:token]    || auth_options['token']
    end

    def authenticate!
      response = GunBroker::API.post('/Users/AccessToken', { username: @username, password: @password })
      @token = response['accessToken']
    end

    # Sends a DELETE request to deactivate the current access token.
    def deauthenticate!
      GunBroker::API.delete('/Users/AccessToken', {}, { 'X-AccessToken' => @token })
      @token = nil
    end

    def items
      response = GunBroker::API.get('/Items', { 'SellerName' => @username }, { 'X-AccessToken' => @token })

      response['results'].map do |result|
        GunBroker::Item.new(result)
      end
    end

  end
end
