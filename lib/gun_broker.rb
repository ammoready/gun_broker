require 'gun_broker/version'

require 'gun_broker/api'
require 'gun_broker/category'
require 'gun_broker/error'
require 'gun_broker/feedback'
require 'gun_broker/item'
require 'gun_broker/response'
require 'gun_broker/user'

module GunBroker

  # Sets the developer key obtained from GunBroker.com.
  # @param dev_key [String]
  def self.dev_key=(dev_key)
    @@dev_key = dev_key
  end

  # Returns the set developer key, or raises GunBroker::Error if not set.
  # @raise [GunBroker::Error] If the {.dev_key} has not been set.
  # @return [String] The developer key.
  def self.dev_key
    raise GunBroker::Error.new('GunBroker developer key not set.') unless dev_key_present?
    @@dev_key
  end

  # Determines if this library will use the production API or the 'sandbox' API.
  # @param sandbox [Boolean]
  def self.sandbox=(sandbox)
    @@sandbox = sandbox
  end

  # If `true`, this library will use the 'sandbox' GunBroker API.
  # @return [Boolean]
  def self.sandbox
    defined?(@@sandbox) ? @@sandbox : false
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

  private

  def self.dev_key_present?
    defined?(@@dev_key) && !@@dev_key.nil? && !@@dev_key.empty?
  end

end
