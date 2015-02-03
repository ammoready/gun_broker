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

    # Finds a specific user's Item by ID.
    def find(item_id)
      # HACK: This has to filter through `#all`, since the GunBroker API currently has no way to scope the `/Items/{itemID}` endpoint by user.
      if all.select { |item| item.id.to_s == item_id.to_s }.first
        GunBroker::Item.find(item_id)
      else
        nil
      end
    end

    # Same as `#find` but raises GunBroker::Error::NotFound if no item is found.
    def find!(item_id)
      item = find(item_id)
      raise GunBroker::Error::NotFound.new("Couldn't find item with ID '#{item_id}'") if item.nil?
      item
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
