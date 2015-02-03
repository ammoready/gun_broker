require 'gun_broker/token_header'

module GunBroker
  class User

    include GunBroker::TokenHeader

    attr_reader :username
    attr_reader :token

    def initialize(username, auth_options = {})
      @username = username
      @password = auth_options[:password] || auth_options['password']
      @token    = auth_options[:token]    || auth_options['token']
    end

    # POST /Users/AccessToken
    def authenticate!
      response = GunBroker::API.post('/Users/AccessToken', { username: @username, password: @password })
      @token = response['accessToken']
    end

    # Sends a DELETE request to deactivate the current access token.
    # DELETE /Users/AccessToken
    def deauthenticate!
      GunBroker::API.delete('/Users/AccessToken', {}, token_header(@token))
      @token = nil
      true  # Explicit `true` so this method won't return the `nil` set above.
    end
    alias_method :revoke_access_token!, :deauthenticate!

    # GET /Users/ContactInfo
    def contact_info
      GunBroker::API.get('/Users/ContactInfo', { 'UserName' => @username }, token_header(@token))
    end

    def items
      ItemsDelegate.new(self)
    end

  end
end
