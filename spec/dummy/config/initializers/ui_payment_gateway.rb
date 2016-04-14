module ShiftCommerce
  UiPaymentGateway.config do |config|
    config.current_cart_method = :current_cart
    config.order_model = "Order"
  end
end