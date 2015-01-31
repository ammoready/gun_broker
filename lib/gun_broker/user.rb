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
      true  # Explicit `true` so this method won't return the `nil` set above.
    end
    alias_method :revoke_access_token!, :deauthenticate!

    def items
      response = GunBroker::API.get('/Items', { 'SellerName' => @username }, { 'X-AccessToken' => @token })
      response['results'].map { |result| GunBroker::Item.new(result) }
    end

    def items_unsold
      response = GunBroker::API.get('/ItemsUnsold', {}, { 'X-AccessToken' => @token })
      response['results'].map { |result| GunBroker::Item.new(result) }
    end
    alias_method :unsold, :items_unsold

    def items_sold
      response = GunBroker::API.get('/ItemsSold', {}, { 'X-AccessToken' => @token })
      response['results'].map { |result| GunBroker::Item.new(result) }
    end
    alias_method :sold, :items_sold

    def items_bid_on
      response = GunBroker::API.get('/ItemsBidOn', {}, { 'X-AccessToken' => @token })
      response['results'].map { |result| GunBroker::Item.new(result) }
    end
    alias_method :buying, :items_bid_on

    def items_won
      response = GunBroker::API.get('/ItemsWon', {}, { 'X-AccessToken' => @token })
      response['results'].map { |result| GunBroker::Item.new(result) }
    end
    alias_method :bought, :items_won

  end
end
