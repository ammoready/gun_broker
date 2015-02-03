module GunBroker
  module TokenHeader

    protected

    def token_header(token)
      raise GunBroker::Error.new("No token given.") if token.nil?
      { 'X-AccessToken' => token }
    end

  end
end
