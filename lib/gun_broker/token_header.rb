module GunBroker
  # Holds helper methods dealing with a User's {User#token access token}.
  module TokenHeader

    protected

    def token_header(token)
      raise GunBroker::Error.new("No token given.") if token.nil?
      { 'X-AccessToken' => token }
    end

  end
end
