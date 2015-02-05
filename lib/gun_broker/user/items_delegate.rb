require 'gun_broker/token_header'

module GunBroker
  class User
    # Used to scope {Item} lookup by {User}.
    class ItemsDelegate

      include GunBroker::TokenHeader

      # @param user [User] A {User} instance to scope items by.
      def initialize(user)
        @user = user
      end

      # Returns all the User's items.
      # @note {API#get! GET} /Items
      # @raise [GunBroker::Error::NotAuthorized] If the {User#token} isn't valid.
      # @raise [GunBroker::Error::RequestError] If there's an issue with the request (usually a `5xx` response).
      # @return [Array<Item>]
      def all
        response = GunBroker::API.get('/Items', { 'SellerName' => @user.username }, token_header(@user.token))
        items_from_results(response['results'])
      end

      # Returns all the items the User has bid on.
      # @note {API#get! GET} /ItemsBidOn
      # @raise (see #all)
      # @return [Array<Item>]
      def bid_on
        response = GunBroker::API.get('/ItemsBidOn', {}, token_header(@user.token))
        items_from_results(response['results'])
      end

      # Finds a specific User's Item by ID. Calls {Item.find} to get full Item details.
      # @raise (see #all)
      # @return [Item] Returns the Item or `nil` if no Item found.
      def find(item_id)
        # HACK: This has to filter through `#all`, since the GunBroker API currently has no way to scope the `/Items/{itemID}` endpoint by user.
        if all.select { |item| item.id.to_s == item_id.to_s }.first
          GunBroker::Item.find(item_id)
        else
          nil
        end
      end

      # Same as {#find} but raises GunBroker::Error::NotFound if no item is found.
      # @raise (see #all)
      # @raise [GunBroker::Error::NotFound] If the User has no Item with `item_id`.
      # @return [Item] Returns the Item or `nil` if no Item found.
      def find!(item_id)
        item = find(item_id)
        raise GunBroker::Error::NotFound.new("Couldn't find item with ID '#{item_id}'") if item.nil?
        item
      end

      # Items the User has bid on, but not won.
      # @note {API#get! GET} /ItemsNotWon
      # @raise (see #all)
      # @return [Array<Item>]
      def not_won
        response = GunBroker::API.get('/ItemsNotWon', {}, token_header(@user.token))
        items_from_results(response['results'])
      end

      # Items the User has sold.
      # @note {API#get! GET} /ItemsSold
      # @raise (see #all)
      # @return [Array<Item>]
      def sold
        response = GunBroker::API.get('/ItemsSold', {}, token_header(@user.token))
        items_from_results(response['results'])
      end

      # Items that were listed, but not sold.
      # @note {API#get! GET} /ItemsUnsold
      # @raise (see #all)
      # @return [Array<Item>]
      def unsold
        response = GunBroker::API.get('/ItemsUnsold', {}, token_header(@user.token))
        items_from_results(response['results'])
      end

      # Items the User has won.
      # @note {API#get! GET} /ItemsWon
      # @raise (see #all)
      # @return [Array<Item>]
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
end
