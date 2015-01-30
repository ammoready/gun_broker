require 'gun_broker/version'

require 'gun_broker/api'
require 'gun_broker/category'
require 'gun_broker/error'
require 'gun_broker/item'
require 'gun_broker/user'

module GunBroker

  def self.dev_key=(dev_key)
    @@dev_key = dev_key
  end

  def self.dev_key
    raise 'GunBroker developer key not set.' unless dev_key_present?
    @@dev_key
  end

  private

  def self.dev_key_present?
    defined?(@@dev_key) && !@@dev_key.nil? && !@@dev_key.empty?
  end

end
