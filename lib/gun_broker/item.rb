module GunBroker
  class Item

    def initialize(attrs = {})
      @attrs = attrs
    end

    def id
      @attrs['itemID']
    end

  end
end