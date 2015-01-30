require 'json'
require 'net/https'

module GunBroker
  class API

    GUNBROKER_API = 'https://api.gunbroker.com/v1'

    def initialize(path, params = {}, headers = {})
      raise "Path must start with '/': #{path}" unless path.start_with?('/')

      @path = path
      @params = params
      @headers = headers
    end

    def self.delete(path, params, headers)
      new(path, params, headers).delete!
    end

    def self.get(path, params)
      new(path, params).get!
    end

    def self.post(path, params)
      new(path, params).post!
    end

    def delete!
      request = Net::HTTP::Delete.new(uri)
      response = get_response(request)

      case response
      when Net::HTTPOK, Net::HTTPSuccess
        JSON.parse(response.body)
      else
        raise "Something went wrong: #{response}"
      end
    end

    def get!
      uri.query = URI.encode_www_form(@params)

      request = Net::HTTP::Get.new(uri)
      response = get_response(request)

      case response
      when Net::HTTPOK, Net::HTTPSuccess
        JSON.parse(response.body)
      else
        raise "Something went wrong: #{response}"
      end
    end

    def post!
      request = Net::HTTP::Post.new(uri)
      request.body = @params.to_json

      response = get_response(request)

      case response
      when Net::HTTPOK, Net::HTTPSuccess
        JSON.parse(response.body)
      else
        raise "Something went wrong: #{response}"
      end
    end

    private

    def get_response(request)
      request['Content-Type'] = 'application/json'
      request['X-DevKey'] = GunBroker.dev_key

      @headers.each { |header, value| request[header] = value }

      Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        http.ssl_version = :SSLv3
        http.request(request)
      end
    end

    def uri
      @uri ||= URI([GUNBROKER_API, @path].join)
    end

  end
end
