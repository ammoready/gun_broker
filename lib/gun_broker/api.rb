require 'json'
require 'net/http'
require 'securerandom'

module GunBroker
  # Generic REST adapter for the GunBroker API.
  class API

    # Root URL of the GunBroker API.
    ROOT_URL = 'https://api.gunbroker.com/v1'

    # Root URL of the GunBroker sandbox API.
    ROOT_URL_SANDBOX = 'https://api.sandbox.gunbroker.com/v1'

    # Used to return the maximum number of results from paginated responses.
    PAGE_SIZE = 300

    # @param path [String] The requested API endpoint.
    # @param params [Hash] (optional) URL params for GET requests; form params for POST request.
    # @param headers [Hash] (optional) Additional headers sent with the request.
    def initialize(path, params = {}, headers = {})
      raise GunBroker::Error.new("Path must start with '/': #{path}") unless path.start_with?('/')

      @base_api_url = GunBroker.sandbox ? ROOT_URL_SANDBOX : ROOT_URL

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

    # Wrapper for {GunBroker::API#multipart_post! `new(*args).multipart_post!`}
    # @param *args Splat arguments passed to {#initialize}.
    def self.multipart_post(*args)
      new(*args).multipart_post!
    end

    # Wrapper for {GunBroker::API#put! `new(*args).put!`}
    # @param *args Splat arguments passed to {#initialize}.
    def self.put(*args)
      new(*args).put!
    end

    # Sends a DELETE request to the given `path`.
    def delete!
      request = Net::HTTP::Delete.new(uri)
      response = get_response(request)
      GunBroker::Response.new(response)
    end

    # Sends a GET request to the given `path`.
    def get!
      uri.query = URI.encode_www_form(@params)

      request = Net::HTTP::Get.new(uri)
      response = get_response(request)
      GunBroker::Response.new(response)
    end

    # Sends a POST request to the given `path`.
    def post!
      request = Net::HTTP::Post.new(uri)
      request.body = @params.to_json

      response = get_response(request)
      GunBroker::Response.new(response)
    end

    # Sends a multipart form POST to the given `path`.
    def multipart_post!
      request = Net::HTTP::Post.new(uri)
      request.body = build_request_body

      response = get_response(request)
      GunBroker::Response.new(response)
    end

    # Sends a PUT request to the given `path`.
    def put!
      request = Net::HTTP::Put.new(uri)
      request.body = @params.to_json

      response = get_response(request)
      GunBroker::Response.new(response)
    end

    private

    def build_request_body
      boundary = ::SecureRandom.hex(15)

      @headers['Content-Type'] = "multipart/form-data; boundary=#{boundary}"

      body = []
      body << "--#{boundary}\r\n"
      body << "Content-Disposition: form-data; name=\"data\"\r\n"
      body << "\r\n"
      body << "#{@params.to_json}\r\n"
      body << "--#{boundary}--\r\n"

      body.join
    end

    def get_response(request)
      request['Content-Type'] = 'application/json'
      request['X-DevKey'] = GunBroker.dev_key

      @headers.each { |header, value| request[header] = value }

      options = {
        use_ssl: uri.scheme == 'https',
        read_timeout: GunBroker.timeout
      }

      Net::HTTP.start(uri.host, uri.port, options) do |http|
        http.ssl_version = :TLSv1
        http.ciphers = ['RC4-SHA']
        http.request(request)
      end
    rescue Net::ReadTimeout => e
      raise GunBroker::Error::TimeoutError.new("waited for #{GunBroker.timeout} seconds with no response (#{uri}) #{e.inspect}")
    end

    def uri
      @uri ||= URI([@base_api_url, @path].join)
    end

  end
end
