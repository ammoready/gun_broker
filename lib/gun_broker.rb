require 'gun_broker/version'

require 'gun_broker/api'
require 'gun_broker/category'
require 'gun_broker/error'
require 'gun_broker/item'
require 'gun_broker/items_delegate'
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

  private

  def self.dev_key_present?
    defined?(@@dev_key) && !@@dev_key.nil? && !@@dev_key.empty?
  end

end
