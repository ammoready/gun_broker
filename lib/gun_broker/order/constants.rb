module GunBroker
  class Order
    module Constants

      # The carrier responsible for shipping.
      # The keys of this hash should be sent as the `carrier` param when updating shipping on an Order.
      SHIPPING_CARRIERS = {
        1 => 'FedEx',
        2 => 'UPS',
        3 => 'USPS',
      }

      # The flags that are allowed to be toggled (true/false) on an Order.
      ACCEPTED_FLAG_KEYS = %i( payment_received ffl_received order_shipped )

    end
  end
end
