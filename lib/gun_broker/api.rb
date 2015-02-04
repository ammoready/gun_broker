require 'json'
require 'net/https'

module GunBroker
  # Generic REST adapter for the GunBroker API.
  class API

    # Root URL of the GunBroker API.
    GUNBROKER_API = 'https://api.gunbroker.com/v1'

    # @param path [String] The requested API endpoint.
    # @param params [Hash] (optional) URL params for GET requests; form params for POST request.
    # @param headers [Hash] (optional) Additional headers sent with the request.
    def initialize(path, params = {}, headers = {})
      raise "Path must start with '/': #{path}" unless path.start_with?('/')

      @path = path
      @params = params
      @headers = headers
    end

    # Wrapper for {GunBroker::API#delete! `new(*args).delete!`}
    # @param *args Splat arguments passed to {#initialize}.
    def self.delete(*args)
      new(*args).delete!
    end

    # Wrapper for {GunBroker::API#get! `new(*args).get!`}
    # @param *args Splat arguments passed to {#initialize}.
    def self.get(*args)
      new(*args).get!
    end

    # Wrapper for {GunBroker::API#post! `new(*args).post!`}
    # @param *args Splat arguments passed to {#initialize}.
    def self.post(*args)
      new(*args).post!
    end

    # Sends a DELETE request to the given `path`.
    def delete!
      request = Net::HTTP::Delete.new(uri)
      response = get_response(request)
      handle_response(response)
    end

    # Sends a GET request to the given `path`.
    def get!
      uri.query = URI.encode_www_form(@params)

      request = Net::HTTP::Get.new(uri)
      response = get_response(request)
      handle_response(response)
    end

    # Sends a POST request to the given `path`.
    def post!
      request = Net::HTTP::Post.new(uri)
      request.body = @params.to_json

      response = get_response(request)
      handle_response(response)
    end

    private

    def get_response(request)
      request['Content-Type'] = 'application/json'
      request['X-DevKey'] = GunBroker.dev_key

      @headers.each { |header, value| request[header] = value }

      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        http.ssl_version = :SSLv3
        http.request(request)
      end
    end

    def handle_response(response)
      case response
      when Net::HTTPOK, Net::HTTPSuccess
        JSON.parse(response.body)
      when Net::HTTPUnauthorized
        raise GunBroker::Error::NotAuthorized.new(response)
      else
        raise GunBroker::Error::RequestError.new(response)
      end
    end

    def uri
      @uri ||= URI([GUNBROKER_API, @path].join)
    end

  end
end
