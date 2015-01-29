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

    def self.post(path, params)
      new(path, params).post!
    end

    def post!
      uri = URI([GUNBROKER_API, @path].join)

      request = Net::HTTP::Post.new(uri)
      request['Content-Type'] = 'application/json'
      request['X-DevKey'] = GunBroker.dev_key
      request.body = @params.to_json

      response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        http.ssl_version = :SSLv3

        http.request(request)
      end

      case response
      when Net::HTTPOK, Net::HTTPSuccess
        JSON.parse(response.body)
      else
        raise "Something went wrong: #{response}"
      end
    end

  end
end
