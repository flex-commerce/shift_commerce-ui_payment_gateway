require "active_merchant"
module ShiftCommerce
  module UiPaymentGateway
    class PaypalExpressEngine
      def initialize(cart:, gateway_class: ::ActiveMerchant::Billing::PaypalExpressGateway, config: Config.instance, request:, success_url:, cancel_url:)
        self.cart = cart
        self.request = request
        self.gateway = gateway_class.new({login: config.paypal_login, password: config.paypal_password, signature: config.paypal_signature})
        self.success_url = success_url
        self.cancel_url = cancel_url
      end
      # @param [Cart] cart The cart that the payment is for
      # @return [String] The URL to redirect the user to
      def setup_payment(cart)
        response = gateway.setup_purchase 1000,
                                          ip: request.remote_ip,
                                          return_url: success_url,
                                          cancel_return_url: cancel_url,
                                          currency: ::ShiftCommerce::UiPaymentGateway::DEFAULT_CURRENCY
        gateway.redirect_url_for(response.token)
      end

      private

      attr_accessor :cart, :gateway, :request, :success_url, :cancel_url
    end
  end
end