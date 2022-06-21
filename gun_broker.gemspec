# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gun_broker/version'

Gem::Specification.new do |spec|
  spec.name          = "gun_broker"
  spec.version       = GunBroker::VERSION
  spec.authors       = ["Dale Campbell", "Jeffrey Dill"]
  spec.email         = ["oshuma@gmail.com", "jeffdill2@gmail.com"]
  spec.summary       = "GunBroker.com API Ruby library"
  spec.homepage      = "https://github.com/ammoready/gun_broker"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.3"
  spec.add_development_dependency "pry", "~> 0.10"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.11"
  spec.add_development_dependency "simplecov", "~> 0.21"
  spec.add_development_dependency "webmock", "~> 3.14"
  spec.add_development_dependency "yard", "~> 0.9"
end
