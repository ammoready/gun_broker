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
        raise GunBroker::Error::NotAuthorized.new(@response.body)
      when Net::HTTPNotFound
        raise GunBroker::Error::NotFound.new(@response.body)
      else
        raise GunBroker::Error::RequestError.new(@response.body)
      end
    end

    # @param key [String] Key from the response JSON to read.
    # @return [String, Array, Hash] Whatever object is the value of `key` or `nil` if the key doesn't exist.
    def [](key)
      @data[key]
    end

    # @return [Hash] The response body as a Hash.
    def body
      @data
    end

    # Like Hash#fetch
    # @param [Object] A key from the response JSON.
    # @raise [KeyError] If `key` is not in the response.
    # @return [Object] The value for `key`.
    def fetch(key)
      @data.fetch(key)
    end

  end
end
