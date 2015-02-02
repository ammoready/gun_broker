module GunBroker
  class Item

    def self.find(item_id)
      new(GunBroker::API.get("/Items/#{item_id}"))
    end

    def initialize(attrs = {})
      @attrs = attrs
    end

    def id
      @attrs['itemID']
    end

    def [](key)
      @attrs[key]
    end

  end
end
