module GunBroker
  # Represents a page of GunBroker items (listings).
  class ItemsAsPage

    # @param attrs [Hash] The attributes required to fetch items from the API.
    def initialize(attributes = {})
      @attributes = attributes
    end

    # @return [Array<Item>]
    def fetch_items
      @attributes[:params].merge!({
        'PageIndex' => @attributes[:page_index],
        'PageSize'  => @attributes[:page_size]
      })
      response = GunBroker::API.get(@attributes[:endpoint], @attributes[:params], @attributes[:token_header])

      response['results'].map { |result| GunBroker::Item.new(result) }
    end

  end
end
