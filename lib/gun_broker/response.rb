module GunBroker
  # Wrapper class for the GunBroker API response JSON.
  class Response

    # @param response [Net::HTTPResponse] Response returned from the API.
    def initialize(response)
      @response = response

      case @response
      when Net::HTTPOK, Net::HTTPSuccess
        @data = JSON.parse(@response.body)
      when Net::HTTPUnauthorized
        raise GunBroker::Error::NotAuthorized.new(@response)
      when Net::HTTPNotFound
        raise GunBroker::Error::NotFound.new(@response)
      else
        raise GunBroker::Error::RequestError.new(@response)
      end
    end

    # @param key [String] Key from the response JSON to read.
    # @return [String, Array, Hash] Whatever object is the value of `key` or `nil` if the key doesn't exist.
    def [](key)
      @data[key]
    end

  end
end
