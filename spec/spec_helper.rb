require 'rspec'
require 'webmock/rspec'

Dir['./spec/support/**/*.rb'].each { |support| require support }

require 'gun_broker'

RSpec.configure do |config|
  config.include Fixtures
end
