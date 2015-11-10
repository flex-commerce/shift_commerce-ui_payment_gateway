module ShiftCommerce
  UiPaymentGateway.config do |config|
    config.paypal_login = "gary.taylor_api1.flexcommerce.com"
    config.paypal_password = "CXLBLQM64B6AXULK"
    config.paypal_signature = "ALYGfT1J93GLRZF-3Y94ce-Z4UZgAsHIQqBoD5p.DabVWhLPVXkcHJw0"
    config.order_model = "Order"
    config.base_controller = "::ApplicationController"
  end
end