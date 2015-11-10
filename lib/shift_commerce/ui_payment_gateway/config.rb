module ShiftCommerce
  module UiPaymentGateway
    class Config
      include Singleton
      attr_accessor :paypal_login, :paypal_password, :paypal_signature, :order_model, :base_controller
    end
  end
end