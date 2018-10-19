require 'gun_broker/token_header'

module GunBroker
  class User
    # Used to scope {Order} actions by {User}.
    class OrdersDelegate

      include GunBroker::TokenHeader

      # @param user [User] A {User} instance to scope orders by.
      def initialize(user)
        @user = user
      end

      # Finds an Order by ID. Calls {Order.find} to get full Order details.
      # @return [Order] Returns the Order or `nil` if no Order found.
      def find(order_id)
        GunBroker::Order.find(order_id)
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
