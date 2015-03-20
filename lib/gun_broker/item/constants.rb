module GunBroker
  class Item
    # Holds constant values for Item.
    module Constants

      # Options for auto-relisting.
      AUTO_RELIST = {
        1 => 'Do Not Relist',
        2 => 'Relist Until Sold',
        3 => 'Relist Fixed Count',
      }

      # Condition options.
      CONDITION = {
        1 => 'Factory New',
        2 => 'New Old Stock',
        3 => 'Used',
      }

      # The return policy / inspection period for the item.
      INSPECTION_PERIOD = {
        1  => 'AS IS - No refund or exchange',
        2  => 'No refund but item can be returned for exchange or store credit within fourteen days',
        3  => 'No refund but item can be returned for exchange or store credit within thirty days',
        4  => 'Three Days from the date the item is received',
        5  => 'Three Days from the date the item is received, including the cost of shipping',
        6  => 'Five Days from the date the item is received',
        7  => 'Five Days from the date the item is received, including the cost of shipping',
        8  => 'Seven Days from the date the item is received',
        9  => 'Seven Days from the date the item is received, including the cost of shipping',
        10 => 'Fourteen Days from the date the item is received',
        11 => 'Fourteen Days from the date the item is received, including the cost of shipping',
        12 => '30 day money back guarantee',
        13 => '30 day money back guarantee including the cost of shipping',
      }

      # How long an auction listing should last.
      AUCTION_DURATION = {
        1  => 'One day',
        3  => 'Three days',
        5  => 'Five days',
        7  => 'Seven days',
        9  => 'Nine days',
        10 => 'Ten days',
        11 => 'Eleven days',
        12 => 'Twelve days',
        13 => 'Thirteen days',
        14 => 'Fourteen days',
      }

      # How long fixed price listing should last.
      FIXED_PRICE_DURATION = {
        30 => 'Thirty days (Fixed price items only)',
        60 => 'Sixty days (Fixed price items only)',
        90 => 'Ninety days (Fixed price items only)',
      }

      # The payment methods accepted by the seller for this Item.
      # The keys of this hash should be sent as `true` or `false` in the `paymentMethods` param.
      PAYMENT_METHODS = {
        'seeItemDesc' => 'See Item Description',
        'amex' => 'American Express',
        'cod' => 'Cash on Delivery',
        'certifiedCheck' => 'Certified Check',
        'check' => 'Check',
        'discover' => 'Discover Card',
        'escrow' => 'Escrow',
        'moneyOrder' => 'Money Order',
        'payPal' => 'PayPal',
        'USPSMoneyOrder' => 'USPS Money Order',
        'visaMastercard' => 'Visa / Mastercard',
      }

      # The type of shipping offered by the seller of this Item.
      # The keys of this hash should be sent as `true` or `false` in the `shippingClassesSupported` param.
      SHIPPING_CLASSES = {
        'overnight' => 'Overnight',
        'twoDay' => 'Two Day',
        'threeDay' => 'Three Day',
        'ground' => 'Ground',
        'firstClass' => 'First Class',
        'priority' => 'Priority',
        'other' => 'Other',
      }

      # Who pays for shipping.
      # The key should be sent as the `whoPaysForShipping` param.
      SHIPPING_PAYER = {
        1  => 'See item description',
        2  => 'Seller pays for shipping',
        4  => 'Buyer pays actual shipping cost',
        8  => 'Buyer pays fixed amount',
        16 => 'Use shipping profile',
      }

    end
  end
end
