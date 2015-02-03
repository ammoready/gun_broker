require 'gun_broker/token_header'

module GunBroker
  class ItemsDelegate

    include GunBroker::TokenHeader

    def initialize(user)
      @user = user
    end

    # GET /Items
    def all
      response = GunBroker::API.get('/Items', { 'SellerName' => @user.username }, token_header(@user.token))
      items_from_results(response['results'])
    end

    # GET /ItemsBidOn
    def bid_on
      response = GunBroker::API.get('/ItemsBidOn', {}, token_header(@user.token))
      items_from_results(response['results'])
    end

    # GET /ItemsNotWon
    def not_won
      response = GunBroker::API.get('/ItemsNotWon', {}, token_header(@user.token))
      items_from_results(response['results'])
    end

    # GET /ItemsSold
    def sold
      response = GunBroker::API.get('/ItemsSold', {}, token_header(@user.token))
      items_from_results(response['results'])
    end

    # GET /ItemsUnsold
    def unsold
      response = GunBroker::API.get('/ItemsUnsold', {}, token_header(@user.token))
      items_from_results(response['results'])
    end

    # GET /ItemsWon
    def won
      response = GunBroker::API.get('/ItemsWon', {}, token_header(@user.token))
      items_from_results(response['results'])
    end

    private

    def items_from_results(results)
      results.map { |result| GunBroker::Item.new(result) }
    end

  end
end
