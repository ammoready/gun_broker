require 'gun_broker/token_header'
require 'gun_broker/item/constants'

module GunBroker
  class User
    # Used to scope {Order} actions by {User}.
    class OrdersDelegate

      include GunBroker::TokenHeader
      include GunBroker::Item::Constants

      # @param user [User] A {User} instance to scope orders by.
      def initialize(user)
        @user = user
      end

      # Finds a specific User's Order by ID. Calls {Order.find} to get full Order details.
      # @raise (see #sold)
      # @return [Order] Returns the Order or `nil` if no Order found.
      def find(order_id)
        GunBroker::Order.find(order_id, {}, token_header(@user.token))
      end

      # Same as {#find} but raises GunBroker::Error::NotFound if no order is found.
      # @raise [GunBroker::Error::NotFound] If the User has no Order with `order_id`.
      # @return [Order] Returns the Order.
      def find!(order_id)
        order = find(order_id)
        raise GunBroker::Error::NotFound.new("Couldn't find order with ID '#{order_id}'") if order.nil?
        order
      end

      # Sold Orders for the User.
      # @param options [Hash] {ItemID=>ItemID}
      # @note {API#get! GET} /OrdersSold
      # @return [Array<Order>]
      def sold(options = {})
        params = [
          *params_for(:timeframe),
          *params_for(:itemid, options)
        ].to_h

        @sold ||= fetch_orders(:OrdersSold, params)
      end

      # Submits shipping details for an {Order}.
      # @param (see #submit_shipping!)
      # @return [GunBroker::Order] The updated Order instance or `false` if update fails.
      def submit_shipping(*args)
        submit_shipping!(*args)
      rescue GunBroker::Error
        false
      end

      # Same as {#submit_shipping} but raises exceptions on error.
      # @param order_id [Integer, String] ID of the Order to update.
      # @param tracking_number [String] The tracking number of the shipment.
      # @param carrier_name [String] The name of the carrier of the shipment.
      # @raise [GunBroker::Error::NotAuthorized] If the {User#token `@user` token} isn't valid.
      # @raise [GunBroker::Error::RequestError] If the Order attributes are not valid or required attributes are missing.
      # @return [GunBroker::Order] The updated Order instance.
      def submit_shipping!(order_id, tracking_number, carrier_name = nil)
        carrier_key = SHIPPING_CARRIERS.find { |k, v| v.casecmp(carrier_name).zero? }.try(:first)
        params = {
          'TrackingNumber' => tracking_number,
          'Carrier' => carrier_key,
        }

        GunBroker::API.put("/Orders/#{order_id}/Shipping", cleanup_nil_params(params), token_header(@user.token))
        find!(order_id)
      end

      private

      def fetch_orders(endpoint, params = {})
        cleanup_nil_params(params)
        params.merge!('PageSize' => GunBroker::API::PAGE_SIZE)

        endpoint = ['/', endpoint.to_s].join
        response = GunBroker::API.get(endpoint, params, token_header(@user.token))
        number_of_pages = (response['count'] / GunBroker::API::PAGE_SIZE.to_f).ceil

        if number_of_pages > 1
          _orders_from_results = orders_from_results(response['results'])

          number_of_pages.times do |page_number|
            page_number += 1
            next if page_number == 1

            params.merge!({ 'PageIndex' => page_number })
            response = GunBroker::API.get(endpoint, params, token_header(@user.token))
            _orders_from_results.concat(orders_from_results(response['results']))
          end

          _orders_from_results
        else
          orders_from_results(response['results'])
        end
      end

      def orders_from_results(results)
        # TODO: Ignore non-US orders.
        results.map { |result| GunBroker::Order.new(result) }
      end

      def params_for(key, options = {})
        case key
        when :timeframe
          { 'TimeFrame' => GunBroker::API::MAX_ORDERS_TIME_FRAME }
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
