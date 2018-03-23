require 'gun_broker/version'

require 'gun_broker/api'
require 'gun_broker/category'
require 'gun_broker/error'
require 'gun_broker/feedback'
require 'gun_broker/item'
require 'gun_broker/items_as_page'
require 'gun_broker/response'
require 'gun_broker/user'

module GunBroker

  WEB_URL = "https://www.gunbroker.com"
  WEB_URL_SANDBOX = "https://www.sandbox.gunbroker.com"

  # Sets the developer key obtained from GunBroker.com.
  # @param api [Boolean] whether to use api endpoint or public website endpoint
  def self.base_url(api: true)
    if sandbox?
      return API::ROOT_URL_SANDBOX if api
      WEB_URL_SANDBOX
    else
      return API::ROOT_URL if api
      WEB_URL
    end
  end

  # Sets the developer key obtained from GunBroker.com.
  # @param dev_key [String]
  def self.dev_key=(_dev_key)
    @@dev_key = _dev_key
  end

  # Returns the set developer key, or raises GunBroker::Error if not set.
  # @raise [GunBroker::Error] If the {.dev_key} has not been set.
  # @return [String] The developer key.
  def self.dev_key
    raise GunBroker::Error.new('GunBroker developer key not set.') unless dev_key_present?
    @@dev_key
  end

  # Set URL for remote proxy (including host, port, user, and password)
  # @return [String] Defaults to `nil`.
  def self.proxy_url=(_proxy_url)
    @@proxy_url = _proxy_url
  end

  # Fully-qualified URL for remote proxy (including host, port, user, and password)
  # @return [String] Defaults to `nil`.
  def self.proxy_url
    defined?(@@proxy_url) ? @@proxy_url : nil
  end

  # Convenience method for finding out if a proxy_url has been set
  # @return [Boolean] Defaults to `false`.
  def self.proxy_url?
    defined?(@@proxy_url) && ! @@proxy_url.nil? || false
  end

  # Determines if this library will use the production API or the 'sandbox' API.
  # @param sandbox [Boolean]
  def self.sandbox=(_sandbox)
    @@sandbox = _sandbox
  end

  # If `true`, this library will use the 'sandbox' GunBroker API.
  # @return [Boolean] Defaults to `false`.
  def self.sandbox
    defined?(@@sandbox) ? @@sandbox : false
  end

  # An alias to {.sandbox} method
  def self.sandbox?
    sandbox
  end

  # Returns a hash containing the time on GunBroker's servers in UTC
  # and the current version of the GunBroker API.
  #
  # For example:
  #
  #     {
  #       "gunBrokerTime" => "2015-02-06T20:23:08Z",
  #       "gunBrokerVersion" => "6 4.4.2.12"
  #     }
  #
  # @return [Hash] Containing the time and API version.
  def self.time
    GunBroker::API.get('/GunBrokerTime')
  end

  # Determines how long to wait on the API until raising a GunBroker::Error::TimeoutError.
  # @param value [Integer]
  def self.timeout=(value)
    @@timeout = value
  end

  # Amount (in seconds) to wait before raising a GunBroker::Error::TimeoutError
  # @return [Integer] Defaults to `30`.
  def self.timeout
    defined?(@@timeout) ? @@timeout : 30
  end

  private

  def self.dev_key_present?
    defined?(@@dev_key) && !@@dev_key.nil? && !@@dev_key.empty?
  end

end
