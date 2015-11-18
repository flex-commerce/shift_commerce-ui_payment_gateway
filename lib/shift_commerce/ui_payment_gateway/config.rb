module ShiftCommerce
  module UiPaymentGateway
    class Config
      include Singleton
      attr_accessor :paypal_login, :paypal_password, :paypal_signature, :current_cart_method, :order_model
    end
  end
end