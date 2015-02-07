module GunBroker
  # Handles feedback about and by a {User}.
  class Feedback

    # @param user_id [Integer, String] Return feedback by this User's ID.
    # @return [Array<Feedback>] An array of the User's feedback.
    def self.all(user_id)
      response = GunBroker::API.get("/Feedback/#{user_id}")
      response['results'].map { |attrs| new(attrs) }
    end

    # @param user_id [Integer, String] Get feedback summary about the `user_id`.
    # @return [GunBroker::Response]
    def self.summary(user_id)
      GunBroker::API.get("/Feedback/Summary/#{user_id}")
    end

    # @param attrs [Hash] The JSON attributes from the API response.
    def initialize(attrs = {})
      @attrs = attrs
    end

    # @return [GunBroker::Item] The Item this feedback is about.
    #
    # See also: {GunBroker::Item.find}
    def item
      GunBroker::Item.find(@attrs['itemID'])
    end

  end
end
