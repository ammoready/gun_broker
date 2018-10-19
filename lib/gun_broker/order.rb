module GunBroker
  # Represents a GunBroker order (listing).
  class Order

    # TODO: Refactor this, #attributes, and #[] into a module.
    # @return [Hash] Attributes parsed from the JSON response.
    attr_reader :attrs

    # @param order_id [Integer, String] The ID of the Order to find.
    # @return [Order] An Order instance or `nil` if no Order with `order_id` exists.
    def self.find(order_id)
      find!(order_id)
    rescue GunBroker::Error::NotFound
      nil
    end

    # Same as {.find} but raises GunBroker::Error::NotFound if no Order is found.
    # @param (see .find)
    # @raise [GunBroker::Error::NotFound] If no Order with `order_id` exists.
    # @return (see .find)
    def self.find!(order_id)
      response = GunBroker::API.get("/Orders/#{order_id}")
      new(response.body)
    end

    # @param attrs [Hash] The JSON attributes from the API response.
    def initialize(attrs = {})
      @attrs = attrs
    end

    # @return [Integer] The Order ID.
    def id
      @attrs['orderID']
    end

    # @return [Hash] Attributes parsed from the JSON response.
    def attributes
      @attrs
    end

    # @return [String] FFL Number (if applicable) for this Order.
    def ffl_number
      @attrs['fflNumber']
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

    # @return [Float] Total sales tax for this Order.
    def sales_tax
      @attrs['salesTaxTotal']
    end

    # @return [Float] Total sales amount for this Order.
    def order_total
      @attrs['orderTotal']
    end

    # @return [String] Payment method used for this Order.
    def payment_method
      @attrs['paymentMethods']
    end

    # @param key [String] An Order attribute name (from the JSON response).
    # @return The value of the given `key` or `nil`.
    def [](key)
      @attrs[key]
    end

  end
end