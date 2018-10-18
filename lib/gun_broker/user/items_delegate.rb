require 'gun_broker/token_header'

module GunBroker
  class User
    # Used to scope {Item} actions by {User}.
    class ItemsDelegate

      include GunBroker::TokenHeader

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
        # NOTE: this endpoint will not return items that were sold
        @all ||= fetch_items(:Items, params_for(:sellername))
      end

      # Returns all the items the User has bid on.
      # @note {API#get! GET} /ItemsBidOn
      # @return [Array<Item>]
      def bid_on
        @bid_on ||= fetch_items(:ItemsBidOn)
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
      # @raise [GunBroker::Error::NotFound] If the User has no Item with `item_id`.
      # @return [Item] Returns the Item or `nil` if no Item found.
      def find!(item_id)
        item = find(item_id)
        raise GunBroker::Error::NotFound.new("Couldn't find item with ID '#{item_id}'") if item.nil?
        item
      end

      # Items the User has bid on, but not won.
      # @note {API#get! GET} /ItemsNotWon
      # @return [Array<Item>]
      def not_won
        @not_won ||= fetch_items(:ItemsNotWon, params_for(:timeframe))
      end

      # Returns Items that are currently selling.
      # @param options [Hash] {ItemID=>ItemID}.
      # @note {API#get! GET} /Items
      # @raise [GunBroker::Error::NotAuthorized] If the {User#token} isn't valid.
      # @raise [GunBroker::Error::RequestError] If there's an issue with the request (usually a `5xx` response).
      # @return [Array<Item>]
      def selling(options = {})
        params = [
          *params_for(:sellername),
          *params_for(:itemid, options)
        ].to_h

        @selling ||= fetch_items(:Items, params)
      end

      # Items the User has sold.
      # @param options [Hash] {ItemID=>ItemID}.
      # @note {API#get! GET} /ItemsSold
      # @return [Array<Item>]
      def sold(options = {})
        params = [
          *params_for(:timeframe),
          *params_for(:itemid, options)
        ].to_h

        @sold ||= fetch_items(:ItemsSold, params)
      end

      # Items that were listed, but not sold.
      # @param options [Hash] {ItemID=>ItemID}.
      # @note {API#get! GET} /ItemsUnsold
      # @return [Array<Item>]
      def unsold(options = {})
        params = [
          *params_for(:timeframe),
          *params_for(:itemid, options)
        ].to_h

        @unsold ||= fetch_items(:ItemsUnsold, params)
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
      # @return [Array<Item>]
      def won
        @won ||= fetch_items(:ItemsWon, params_for(:timeframe))
      end

      private

      def fetch_items(endpoint, params = {})
        cleanup_nil_params(params)
        params.merge!('PageSize' => GunBroker::API::PAGE_SIZE)

        endpoint = ['/', endpoint.to_s].join
        response = GunBroker::API.get(endpoint, params, token_header(@user.token))
        number_of_pages = (response['count'] / GunBroker::API::PAGE_SIZE.to_f).ceil

        if number_of_pages > 1
          _items_from_results = items_from_results(response['results'])

          number_of_pages.times do |page_number|
            page_number += 1
            next if page_number == 1

            params.merge!({ 'PageIndex' => page_number })
            response = GunBroker::API.get(endpoint, params, token_header(@user.token))
            _items_from_results.concat(items_from_results(response['results']))
          end

          _items_from_results
        else
          items_from_results(response['results'])
        end
      end

      def items_from_results(results)
        results.map { |result| GunBroker::Item.new(result) }
      end

      def params_for(key, options = {})
        case key
        when :sellername
          { 'SellerName' => @user.username }
        when :timeframe
          { 'TimeFrame' => GunBroker::API::MAX_ITEMS_TIME_FRAME }
        when :itemid
          { 'ItemID' => (options[:item_id] || options["ItemID"]) }
        else
          raise GunBroker::Error.new 'Unrecognized `params_for` key.'
        end
      end

      def cleanup_nil_params(params)
        params.delete_if { |k, v| v.nil? }
      end

    end
  end
end
