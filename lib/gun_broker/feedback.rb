module GunBroker
  class Feedback

    def self.all(user_id)
      response = GunBroker::API.get("/Feedback/#{user_id}")
      response['results'].map { |attrs| new(attrs) }
    end

    def self.summary(user_id)
      GunBroker::API.get("/Feedback/Summary/#{user_id}")
    end

    def initialize(attrs = {})
      @attrs = attrs
    end

    def item
      GunBroker::Item.find(@attrs['itemID'])
    end

  end
end
