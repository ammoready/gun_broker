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

    end
  end
end
