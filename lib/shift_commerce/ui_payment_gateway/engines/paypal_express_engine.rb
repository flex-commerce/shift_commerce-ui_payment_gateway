require "active_merchant"
module ShiftCommerce
  module UiPaymentGateway
    DEFAULT_DESCRIPTION = "THE DEFAULT DESCRIPTION - TO BE CHANGED"
    class PaypalExpressEngine
      def initialize(order:, gateway_class: ::ActiveMerchant::Billing::PaypalExpressGateway, config: Config.instance, request:, success_url:, cancel_url:)
        self.order = order
        self.request = request
        self.gateway = gateway_class.new({login: config.paypal_login, password: config.paypal_password, signature: config.paypal_signature})
        self.success_url = success_url
        self.cancel_url = cancel_url
      end
      # @param [Order] order The order that the payment is for
      # @return [String] The URL to redirect the user to
      def setup_payment(order:)
        shipping_address = order.shipping_address
        response = gateway.setup_purchase 1000,
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

      private

      attr_accessor :order, :gateway, :request, :success_url, :cancel_url
    end
  end
end