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

    # Defaults to 12 (View Last 30 Days), so we need to specify 1 (View All Completed) to get everything.
    TIME_FRAME = 1

    USER_AGENT = "gun_broker rubygems.org/gems/gun_broker v(#{GunBroker::VERSION})"

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
      request['X-DevKey']     = GunBroker.dev_key
      request["User-Agent"]   = USER_AGENT

      @headers.each { |header, value| request[header] = value }

      # using std-lib Timeout module
      # The GunBroker API is so fickle that the 'read_timeout' option might never even get a chance
      Timeout.timeout(GunBroker.timeout) do
        net_http_class.start(uri.host, uri.port, net_http_options) do |http|
          http.ssl_version = :TLSv1
          http.ciphers = ['RC4-SHA']
          http.request(request)
        end
      end
    rescue Timeout::Error, Net::ReadTimeout => e
      raise GunBroker::Error::TimeoutError.new("waited for #{GunBroker.timeout} seconds with no response (#{uri}) #{e.inspect}")
    end

    def net_http_class
      if GunBroker.proxy_url?
        proxy_uri = URI.parse(GunBroker.proxy_url)
        Net::HTTP::Proxy(proxy_uri.host, proxy_uri.port, proxy_uri.user, proxy_uri.password)
      else
        Net::HTTP
      end
    end

    def net_http_options
      {
        use_ssl: uri.scheme == 'https',
        read_timeout: GunBroker.timeout
      }
    end

    def uri
      @uri ||= URI([@base_api_url, @path].join)
    end

  end
end
