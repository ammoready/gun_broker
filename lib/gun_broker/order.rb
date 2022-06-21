module GunBroker
  # Represents a GunBroker order (listing).
  class Order

    # TODO: Refactor this, #attributes, and #[] into a module.
    # @return [Hash] Attributes parsed from the JSON response.
    attr_reader :attrs

    # @param order_id [Integer, String] The ID of the Order to find.
    # @return [Order] An Order instance or `nil` if no Order with `order_id` exists.
    def self.find(order_id, params = {}, headers = {})
      find!(order_id, params, headers)
    rescue GunBroker::Error::NotFound
      nil
    end

    # Same as {.find} but raises GunBroker::Error::NotFound if no Order is found.
    # @param (see .find)
    # @raise [GunBroker::Error::NotFound] If no Order with `order_id` exists.
    # @return (see .find)
    def self.find!(order_id, params = {}, headers = {})
      response = GunBroker::API.get("/Orders/#{order_id}", params, headers)
      new(response.body)
    end

    # @param attrs [Hash] The JSON attributes from the API response.
    def initialize(attrs = {})
      @attrs = attrs
    end

    # @return [Hash] Attributes parsed from the JSON response.
    def attributes
      @attrs
    end

    # @return [Integer] The Order ID.
    def id
      @attrs['orderID']
    end

    # @return [String] FFL Number (if applicable) for this Order.
    def ffl_number
      @attrs['fflNumber']
    end

    # @return [Array] Item IDs of associated items for this Order.
    def item_ids
      (@attrs['items'] || @attrs['orderItemsCollection']).collect { |item| item['itemID'] }
    end

    # @return [Hash] Billing info for this Order.
    def bill_to
      {
        name:         @attrs['billToName'],
        address_1:    @attrs['billToAddress1'],
        address_2:    @attrs['billToAddress2'],
        city:         @attrs['billToCity'],
        state:        @attrs['billToState'],
        zip:          @attrs['billToPostalCode'],
        email:        @attrs['billToEmail'],
        phone:        @attrs['billToPhone']
      }
    end

    # @return [Hash] Shipping info for this Order.
    def ship_to
      {
        name:         @attrs['shipToName'],
        address_1:    @attrs['shipToAddress1'],
        address_2:    @attrs['shipToAddress2'],
        city:         @attrs['shipToCity'],
        state:        @attrs['shipToState'],
        zip:          @attrs['shipToPostalCode'],
        email:        @attrs['shipToEmail'],
        phone:        @attrs['shipToPhone']
      }
    end

    # @return [Float] Total shipping amount for this Order.
    def shipping_total
      @attrs['shipCost']
    end

    # @return [Float] Total sales tax for this Order.
    def sales_tax_total
      @attrs['salesTaxTotal']
    end

    # @return [Float] Total sales amount for this Order.
    def order_total
      @attrs['orderTotal'] || @attrs['totalPrice']
    end

    # @return [String] Payment methods used for this Order.
    def payment_methods
      @attrs['paymentMethod'].values
    end

    # @return [Integer] Status key for this Order.
    def status_key
      @attrs['status'].keys.first.to_i
    end

    # @param key [String] An Order attribute name (from the JSON response).
    # @return The value of the given `key` or `nil`.
    def [](key)
      @attrs[key]
    end

  end
end
