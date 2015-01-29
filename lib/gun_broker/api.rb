require 'json'
require 'net/https'

module GunBroker
  class API

    GUNBROKER_API = 'https://api.gunbroker.com/v1'

    def initialize(path, params = {})
      raise "Path must start with '/': #{path}" unless path.start_with?('/')

      @path = path
      @params = params
    end

    def self.get(path, params)
      new(path, params).get!
    end

    def self.post(path, params)
      new(path, params).post!
    end

    def get!
      uri = URI([GUNBROKER_API, @path].join)
      uri.query = URI.encode_www_form(@params)

      request = Net::HTTP::Get.new(uri)
      response = get_response(uri, request)

      case response
      when Net::HTTPOK, Net::HTTPSuccess
        JSON.parse(response.body)
      else
        raise "Something went wrong: #{response}"
      end
    end

    def post!
      uri = URI([GUNBROKER_API, @path].join)

      request = Net::HTTP::Post.new(uri)
      request.body = @params.to_json

      response = get_response(uri, request)

      case response
      when Net::HTTPOK, Net::HTTPSuccess
        JSON.parse(response.body)
      else
        raise "Something went wrong: #{response}"
      end
    end

    private

    def get_response(uri, request)
      request['Content-Type'] = 'application/json'
      request['X-DevKey'] = GunBroker.dev_key

      Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        http.ssl_version = :SSLv3
        http.request(request)
      end
    end

  end
end
