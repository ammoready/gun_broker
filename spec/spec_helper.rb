require 'simplecov'
SimpleCov.start

require 'rspec'
require 'webmock/rspec'

Dir['./spec/support/**/*.rb'].each { |support| require support }

require 'gun_broker'

RSpec.configure do |config|
  config.include GunBroker::Test::Fixtures
  config.include GunBroker::Test::Headers
  config.include GunBroker::Test::Request
end
