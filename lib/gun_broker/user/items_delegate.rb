require 'gun_broker/token_header'

module GunBroker
  class User
    # Used to scope {Item} actions by {User}.
    class ItemsDelegate

      include GunBroker::TokenHeader

      # Constants to use with the `SellingStatus` param.
      SELLING_STATUS = {
        both:        0,
        selling:     1,
        not_selling: 2,
      }

      # @param user [User] A {User} instance to scope items by.
      def initialize(user)
        @user = user
      end

      # Returns all the User's items (both selling and not selling).
      # @note {API#get! GET} /Items
      # @raise [GunBroker::Error::NotAuthorized] If the {User#token} isn't valid.
      # @raise [GunBroker::Error::RequestError] If there's an issue with the request (usually a `5xx` response).
      # @return [Array<Item>]
      def all
        response = GunBroker::API.get('/Items', {
          'SellerName' => @user.username,
          'SellingStatus' => SELLING_STATUS[:both],
          'PageSize' => GunBroker::API::PAGE_SIZE
        }, token_header(@user.token))
        items_from_results(response['results'])
      end

      # Returns all the items the User has bid on.
      # @note {API#get! GET} /ItemsBidOn
      # @raise (see #all)
      # @return [Array<Item>]
      def bid_on
        response = GunBroker::API.get('/ItemsBidOn', {
          'PageSize' => GunBroker::API::PAGE_SIZE
        }, token_header(@user.token))
        items_from_results(response['results'])
      end

      # Sends a multipart/form-data POST request to create an Item with the given `attributes`.
      # @return [GunBroker::Item] A {Item} instance or `false` if the item could not be created.
      def create(attributes = {})
        create!
      rescue GunBroker::Error
        false
      end

      # Same as {#create} but raises GunBroker::Error::RequestError on failure.
      # @raise [GunBroker::Error::NotAuthorized] If the {User#token `@user` token} isn't valid.
      # @raise [GunBroker::Error::RequestError] If the Item attributes are not valid or required attributes are missing.
      # @return [GunBroker::Item] A {Item} instance.
      def create!(attributes = {})
        response = GunBroker::API.multipart_post('/Items', attributes, token_header(@user.token))
        item_id = response.body['links'].first['title']
        GunBroker::Item.find(item_id)
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
        response = GunBroker::API.get('/ItemsNotWon', {
          'PageSize' => GunBroker::API::PAGE_SIZE
        }, token_header(@user.token))
        items_from_results(response['results'])
      end

      # Returns Items that are currently selling.
      # @param options [Hash] {ItemID=>ItemID}.
      # @note {API#get! GET} /Items
      # @raise [GunBroker::Error::NotAuthorized] If the {User#token} isn't valid.
      # @raise [GunBroker::Error::RequestError] If there's an issue with the request (usually a `5xx` response).
      # @return [Array<Item>]
      def selling(options = {})
        parameters = {
          'ItemID'        => (options[:item_id] || options["ItemID"]),
          'PageSize'      => GunBroker::API::PAGE_SIZE,
          'SellerName'    => @user.username,
          'SellingStatus' => SELLING_STATUS[:selling],
        }.delete_if { |k, v| v.nil? }

        response = GunBroker::API.get('/Items', parameters, token_header(@user.token))
        items_from_results(response['results'])
      end

      # Items the User has sold.
      # @param options [Hash] {ItemID=>ItemID}.
      # @note {API#get! GET} /ItemsSold
      # @raise (see #all)
      # @return [Array<Item>]
      def sold(options = {})
        parameters = {
          'PageSize' => GunBroker::API::PAGE_SIZE,
          'ItemID'   => (options[:item_id] || options["ItemID"]),
        }.delete_if { |k, v| v.nil? }

        response = GunBroker::API.get('/ItemsSold', parameters, token_header(@user.token))
        items_from_results(response['results'])
      end

      # Items that were listed, but not sold.
      # @note {API#get! GET} /ItemsUnsold
      # @raise (see #all)
      # @return [Array<Item>]
      def unsold(options = {})
        parameters = {
          'PageSize' => GunBroker::API::PAGE_SIZE,
          'ItemID'   => (options[:item_id] || options["ItemID"]),
        }.delete_if { |k, v| v.nil? }

        response = GunBroker::API.get('/ItemsUnsold', parameters, token_header(@user.token))
        items_from_results(response['results'])
      end

      # Updates an {Item} with the given attributes.
      # @param (see #update!)
      # @return [GunBroker::Item] The updated Item instance or `false` if update fails.
      def update(*args)
        update!(*args)
      rescue GunBroker::Error
        false
      end

      # Same as {#update} but raises exceptions on error.
      # @param item_id [Integer, String] ID of the Item to update.
      # @param attributes [Hash] The new Item attributes.
      # @raise [GunBroker::Error::NotAuthorized] If the {User#token `@user` token} isn't valid.
      # @raise [GunBroker::Error::RequestError] If the Item attributes are not valid or required attributes are missing.
      # @return [GunBroker::Item] The updated Item instance.
      def update!(item_id, attributes = {})
        GunBroker::API.put("/Items/#{item_id}", attributes, token_header(@user.token))
        GunBroker::Item.find!(item_id)
      end

      # Items the User has won.
      # @note {API#get! GET} /ItemsWon
      # @raise (see #all)
      # @return [Array<Item>]
      def won
        response = GunBroker::API.get('/ItemsWon', {
          'PageSize' => GunBroker::API::PAGE_SIZE
        }, token_header(@user.token))
        items_from_results(response['results'])
      end

      private

      def items_from_results(results)
        results.map { |result| GunBroker::Item.new(result) }
      end

    end
  end
end
