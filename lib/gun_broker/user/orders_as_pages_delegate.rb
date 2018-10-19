require 'gun_broker/token_header'

module GunBroker
  class User
    # Used to scope {OrdersAsPage} actions by {User}.
    class OrdersAsPagesDelegate

      include GunBroker::TokenHeader

      # @param user [User] A {User} instance to scope order pages by.
      # @param options [Hash] { orders_per_page => <number of desired orders per page> (Integer) }.
      def initialize(user, options = {})
        max_page_size = GunBroker::API::PAGE_SIZE
        @user = user
        @orders_per_page = options.fetch(:orders_per_page, max_page_size)

        if @orders_per_page > max_page_size
          raise ArgumentError.new("`orders_per_page` may not exceed #{max_page_size}")
        end
      end

      # Returns pages for orders the User has sold.
      # @note {API#get! GET} /OrdersSold
      # @return [Array<OrdersAsPage>]
      def sold
        @sold ||= build_pages_for(:OrdersSold, { 'TimeFrame' => GunBroker::API::MAX_ORDERS_TIME_FRAME })
      end

      private

      def build_pages_for(endpoint, params = {})
        endpoint = ['/', endpoint.to_s].join
        _token_header = token_header(@user.token)
        response = GunBroker::API.get(endpoint, params.merge({ 'PageSize' => 1 }), _token_header)
        number_of_pages = (response['count'] / @orders_per_page.to_f).ceil
        orders_as_pages = []

        number_of_pages.times do |page_number|
          page_number += 1
          attrs = {
            page_size:    @orders_per_page,
            page_index:   page_number,
            endpoint:     endpoint,
            params:       params,
            token_header: _token_header
          }

          orders_as_pages << GunBroker::OrdersAsPage.new(attrs)
        end

        orders_as_pages
      end

    end
  end
end
