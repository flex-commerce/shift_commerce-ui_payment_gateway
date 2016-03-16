require "active_merchant"
module ShiftCommerce
  module UiPaymentGateway
    DEFAULT_DESCRIPTION = "THE DEFAULT DESCRIPTION - TO BE CHANGED"
    class PaypalExpressEngine
      def initialize(cart:, gateway_class: ::ActiveMerchant::Billing::PaypalExpressGateway, config: Config.instance, request:, success_url:, cancel_url:, convert_address_service: ::ShiftCommerce::UiPaymentGateway::Paypal::ConvertAddress)
        self.cart = cart
        self.request = request
        self.gateway = gateway_class.new({login: config.paypal_login, password: config.paypal_password, signature: config.paypal_signature})
        gateway.class.wiredump_device = config.wiredump_device if config.wiredump_device.present?
        self.success_url = success_url
        self.cancel_url = cancel_url
        self.cart_has_addresses = cart.shipping_address.present?
        self.convert_address_service = convert_address_service
      end

      # @param [Order] cart The cart that the payment is for
      # @return [String] The URL to redirect the user to
      def setup_payment(cart:)
        shipping_address = cart.shipping_address
        items = cart.line_items.map do |li|
          {
              name: li.title,
              number: "Number",
              quantity: li.unit_quantity,
              amount: convert_amount(li.total / li.unit_quantity),
              description: li.title,
              url: "http://www.google.com"
          }
        end
        paypal_params = {ip: request.remote_ip,
                         return_url: success_url,
                         cancel_return_url: cancel_url,
                         currency: ::ShiftCommerce::UiPaymentGateway::DEFAULT_CURRENCY,
                         description: DEFAULT_DESCRIPTION,
                         items: items}
        if shipping_address
          paypal_params.merge! address_override: true,
                               shipping_address: {
                                   name: "#{shipping_address.first_name} #{shipping_address.middle_names} #{shipping_address.last_name}",
                                   address1: shipping_address.address_line_1,
                                   address2: shipping_address.address_line_2,
                                   city: shipping_address.city,
                                   state: shipping_address.state,
                                   country: shipping_address.country,
                                   zip: shipping_address.postcode

                               }
        end
        response = gateway.setup_purchase convert_amount(cart.total), paypal_params

        if response.success?
          gateway.redirect_url_for(response.token)
        else
          raise "An error occured communicating with paypal #{response.message} \n\n#{response.params.to_json}" # @TODO Find out where to get the message from and add it
        end
      end

      # Processes the token - i.e. takes the payment and returns the authorisation code
      # @param [String] token The token to use (comes from params[:token] in the controller)
      # @param [Object] cart The cart for which we are taking payment for
      # @param [Object] payer_id The payer id (comes from params["PayerID"] in the controller)
      # @return [Hash] The authorization id and token to be stored by the application (auth_id: [String], token: [String])
      # @raise [ShiftCommerce::UiPaymentGateway::Exceptions::PaymentNotAccepted] Raised if paypal errors for any reason - the response is available as an attribute on the exception
      def process_token(token:, cart:, payer_id:)
        response = gateway.purchase(convert_amount(cart.total), token: token, payer_id: payer_id, currency: ::ShiftCommerce::UiPaymentGateway::DEFAULT_CURRENCY)
        raise Exceptions::PaymentNotAccepted.new(response) unless response.success?
        return {auth_id: response.authorization, token: response.token}
      end

      def get_shipping_address_attributes(token:)
        #@TODO Can this be cached for the token
        details = gateway.details_for(token)
        convert_address_service.call(details.params["PaymentDetails"]["ShipToAddress"])
      end

      def get_billing_address_attributes(token:)
        #@TODO Can this be cached for the token
        details = gateway.details_for(token)
        convert_address_service.call(details.params["PayerInfo"]["Address"])
      end

      private

      def get_details_from_paypal?
        !cart_has_addresses
      end


      def convert_amount(amount)
        (amount * 100).round
      end

      attr_accessor :cart, :gateway, :request, :success_url, :cancel_url, :cart_has_addresses, :convert_address_service
    end
  end
end