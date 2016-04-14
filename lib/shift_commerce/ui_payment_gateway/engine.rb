require "active_merchant"
module ShiftCommerce
  module UiPaymentGateway
    class Engine < ::Rails::Engine
      isolate_namespace UiPaymentGateway
    end
  end
end
