module ShiftCommerce
  module UiPaymentGateway
    class Config
      include Singleton
      attr_accessor :paypal_login, :paypal_password, :paypal_signature, :current_cart_method, :order_model, :address_model, :shipping_method_model, :test_mode, :wiredump_device, :api_root
    end
  end
end