require "shift_commerce/ui_payment_gateway/engine"
require "shift_commerce/ui_payment_gateway/config"
module ShiftCommerce
  module UiPaymentGateway
    def self.config
      yield Config.instance
    end
    DEFAULT_CURRENCY="GBP"
    autoload :ControllerExtensions, File.expand_path("./ui_payment_gateway/controller_extensions", __dir__)
    autoload :PaymentService, File.expand_path("../../app/services/payment_service", __dir__)
    autoload :PaypalExpressEngine, File.expand_path("./ui_payment_gateway/engines/paypal_express_engine", __dir__)
    autoload :Exceptions, File.expand_path("./ui_payment_gateway/exceptions", __dir__)
    module Paypal
      autoload :PopulateCart, File.expand_path("../../app/services/paypal/populate_cart", __dir__)
    end
  end
end
