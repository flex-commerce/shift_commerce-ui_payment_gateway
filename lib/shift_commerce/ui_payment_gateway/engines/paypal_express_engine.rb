require "active_merchant"
module ShiftCommerce
  module UiPaymentGateway
    DEFAULT_DESCRIPTION = "THE DEFAULT DESCRIPTION - TO BE CHANGED"
    class PaypalExpressEngine
      def initialize(cart:, gateway_class: ::ActiveMerchant::Billing::PaypalExpressGateway, config: Config.instance, request:, success_url:, cancel_url:)
        self.cart = cart
        self.request = request
        self.gateway = gateway_class.new({login: config.paypal_login, password: config.paypal_password, signature: config.paypal_signature})
        self.success_url = success_url
        self.cancel_url = cancel_url
      end
      # @param [Order] cart The cart that the payment is for
      # @return [String] The URL to redirect the user to
      def setup_payment(cart:)
        shipping_address = cart.shipping_address
        response = gateway.setup_purchase convert_amount(cart.total),
                                          ip: request.remote_ip,
                                          return_url: success_url,
                                          cancel_return_url: cancel_url,
                                          currency: ::ShiftCommerce::UiPaymentGateway::DEFAULT_CURRENCY,
                                          address_override: true,
                                          shipping_address: {
                                            name: shipping_address.name,
                                            address1: shipping_address.address_line_1,
                                            address2: shipping_address.address_line_2,
                                            city: shipping_address.city,
                                            state: shipping_address.state,
                                            country: shipping_address.country,
                                            zip: shipping_address.postcode

                                          },
                                          description: DEFAULT_DESCRIPTION,
                                          items: [
                                            {
                                              name: "Name",
                                              number: "Number",
                                              quantity: 1,
                                              amount: 500,
                                              description: "Description",
                                              url: "http://www.google.com"
                                            },
                                            {
                                              name: "Name",
                                              number: "Number",
                                              quantity: 1,
                                              amount: 500,
                                              description: "Description",
                                              url: "http://www.google.com"
                                            }
                                          ]
        gateway.redirect_url_for(response.token)
      end

      def process_token(token:, cart:, payer_id:)
        tmp = gateway.purchase(convert_amount(cart.total), token: token, payer_id: payer_id)
        tmp=1
      end

      private

      def convert_amount(amount)
        (amount * 100).to_i
      end

      attr_accessor :cart, :gateway, :request, :success_url, :cancel_url
    end
  end
end