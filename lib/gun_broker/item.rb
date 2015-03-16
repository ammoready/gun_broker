require 'gun_broker/item/constants'

module GunBroker
  # Represents a GunBroker item (listing).
  class Item

    include GunBroker::Item::Constants

    # TODO: Refactor this, #attributes, and #[] into a module.
    # @return [Hash] Attributes parsed from the JSON response.
    attr_reader :attrs

    # @param item_id [Integer, String] The ID of the Item to find.
    # @return [Item] An Item instance or `nil` if no Item with `item_id` exists.
    def self.find(item_id)
      find!(item_id)
    rescue GunBroker::Error::NotFound
      nil
    end

    # Same as {.find} but raises GunBroker::Error::NotFound if no Item is found.
    # @param (see .find)
    # @raise [GunBroker::Error::NotFound] If no Item with `item_id` exists.
    # @return (see .find)
    def self.find!(item_id)
      response = GunBroker::API.get("/Items/#{item_id}")
      new(response.body)
    end

    # @param attrs [Hash] The JSON attributes from the API response.
    def initialize(attrs = {})
      @attrs = attrs
    end

    # @return [Integer] The Item ID.
    def id
      @attrs['itemID']
    end

    # @return [Hash] Attributes parsed from the JSON response.
    def attributes
      @attrs
    end

    # @return [Category] This Items Category.
    def category
      GunBroker::Category.find(@attrs['categoryID'])
    end

    # @return [String] Title of this Item.
    def title
      @attrs['title']
    end

    # @return [String] GunBroker.com URL for this Item.
    def url
      if GunBroker.sandbox
        "http://www.sandbox.gunbroker.com/Auction/ViewItem.aspx?Item=#{id}"
      else
        "http://www.gunbroker.com/Auction/ViewItem.aspx?Item=#{id}"
      end
    end

    # @param key [String] An Item attribute name (from the JSON response).
    # @return The value of the given `key` or `nil`.
    def [](key)
      @attrs[key]
    end

  end
end
