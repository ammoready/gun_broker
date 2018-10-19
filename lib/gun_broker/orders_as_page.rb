module GunBroker
  # Represents a page of GunBroker orders.
  class OrdersAsPage

    # @param attrs [Hash] The attributes required to fetch orders from the API.
    def initialize(attributes = {})
      @attributes = attributes
    end

    # @return [Array<Order>]
    def fetch_orders
      @attributes[:params].merge!({
        'PageIndex' => @attributes[:page_index],
        'PageSize'  => @attributes[:page_size],
      })
      response = GunBroker::API.get(@attributes[:endpoint], @attributes[:params], @attributes[:token_header])

      response['results'].map { |result| GunBroker::Order.new(result) }
    end

  end
end
