module GunBroker
  class User

    attr_reader :token

    def initialize(username, password)
      @username = username
      @password = password
    end

    def authenticate!
      response = GunBroker::API.post('/Users/AccessToken', { username: @username, password: @password })
      @token = response['accessToken']
    end

    def items
      response = GunBroker::API.get('/Items', { 'SellerName' => @username })
      @items = []

      response['results'].each do |result|
        @items << GunBroker::Item.new(result)
      end

      @items
    end

  end
end
