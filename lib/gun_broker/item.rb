module GunBroker
  # Represents a GunBroker item (listing).
  class Item

    # @return [Hash] Attributes parsed from the JSON response.
    attr_reader :attrs

    # @param item_id [Integer, String] The ID of the Item to find.
    # @return [Item] An Item instance.
    def self.find(item_id)
      new(GunBroker::API.get("/Items/#{item_id}"))
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

    # @return [String] Title of this Item.
    def title
      @attrs['title']
    end

    # @param key [String] An Item attribute name (from the JSON response).
    # @return The value of the given `key` or `nil`.
    def [](key)
      @attrs[key]
    end

  end
end
