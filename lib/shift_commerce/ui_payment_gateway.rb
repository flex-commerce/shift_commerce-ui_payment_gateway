require "shift_commerce/ui_payment_gateway/engine"
require "shift_commerce/ui_payment_gateway/config"
module ShiftCommerce
  module UiPaymentGateway
    def self.config
      yield Config.instance if block_given?
      Config.instance
    end
    DEFAULT_CURRENCY="GBP"
    autoload :ControllerExtensions, File.expand_path("./ui_payment_gateway/controller_extensions", __dir__)
  end
end
