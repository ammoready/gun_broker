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
      GunBroker::API.delete('/Users/AccessToken', {}, token_header)
      @token = nil
      true  # Explicit `true` so this method won't return the `nil` set above.
    end
    alias_method :revoke_access_token!, :deauthenticate!

    def items
      response = GunBroker::API.get('/Items', { 'SellerName' => @username }, token_header)
      items_from_results(response['results'])
    end

    def items_unsold
      response = GunBroker::API.get('/ItemsUnsold', {}, token_header)
      items_from_results(response['results'])
    end
    alias_method :unsold, :items_unsold

    def items_sold
      response = GunBroker::API.get('/ItemsSold', {}, token_header)
      items_from_results(response['results'])
    end
    alias_method :sold, :items_sold

    def items_bid_on
      response = GunBroker::API.get('/ItemsBidOn', {}, token_header)
      items_from_results(response['results'])
    end
    alias_method :buying, :items_bid_on

    def items_won
      response = GunBroker::API.get('/ItemsWon', {}, token_header)
      items_from_results(response['results'])
    end
    alias_method :bought, :items_won

    def items_not_won
      response = GunBroker::API.get('/ItemsNotWon', {}, token_header)
      items_from_results(response['results'])
    end

    private

    def items_from_results(results)
      results.map { |result| GunBroker::Item.new(result) }
    end

    def token_header
      raise GunBroker::Error.new("User @token not set.") if @token.nil?
      { 'X-AccessToken' => @token }
    end

  end
end
