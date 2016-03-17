$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "shift_commerce/ui_payment_gateway/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "shift_commerce-ui_payment_gateway"
  s.version     = ShiftCommerce::UiPaymentGateway::VERSION
  s.authors     = ["Gary Taylor"]
  s.email       = ["gary.taylor@hismessages.com"]
  s.homepage    = ""
  s.summary     = "A payment gateway provider for the front end application for ShiftCommerce"
  s.description = "A payment gateway provider for the front end application for ShiftCommerce"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_development_dependency "rails", "~> 4.2.5"
  s.add_dependency "activemerchant", "~> 1.54"
  s.add_development_dependency "climate_control"

end
