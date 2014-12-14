# -*- encoding: utf-8 -*-
require File.expand_path('../lib/oanda_exchange/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Alexey Glukhov"]
  gem.email         = ["gluhov1985@gmail.com"]
  gem.description   = "OANDA Exchange API"
  gem.summary       = "API for OANDA Exchange Services"
  gem.homepage      = ""

  gem.files         = Dir.glob("lib/**/*")
  gem.name          = "oanda_exchange"
  gem.require_paths = ["lib"]
  gem.version       = OandaExchange::VERSION

  gem.add_runtime_dependency "activesupport"
  gem.add_runtime_dependency "money"  
  gem.add_runtime_dependency "httparty"
end
