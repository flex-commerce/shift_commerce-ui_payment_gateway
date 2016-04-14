module ShiftCommerce
  module UiPaymentGateway
    class Config
      include Singleton
      attr_accessor :current_cart_method, :order_model
    end
  end
end