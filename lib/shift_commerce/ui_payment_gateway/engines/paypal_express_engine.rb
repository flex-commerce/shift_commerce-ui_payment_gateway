require "active_merchant"
module ShiftCommerce
  module UiPaymentGateway
    DEFAULT_DESCRIPTION = "THE DEFAULT DESCRIPTION - TO BE CHANGED"
    class PaypalExpressEngine
      def initialize(cart:, gateway_class: ::ActiveMerchant::Billing::PaypalExpressGateway, config: Config.instance, request:, success_url:, cancel_url:, convert_address_service: ::ShiftCommerce::UiPaymentGateway::Paypal::ConvertAddress, allow_shipping_change: false)
        self.cart = cart
        self.request = request
        self.gateway = gateway_class.new({login: config.paypal_login, password: config.paypal_password, signature: config.paypal_signature})
        gateway.class.wiredump_device = config.wiredump_device if config.wiredump_device.present?
        self.success_url = success_url
        self.cancel_url = cancel_url
        self.cart_has_addresses = cart.shipping_address.present?
        self.convert_address_service = convert_address_service
        self.allow_shipping_change = allow_shipping_change
        self.callback_url = config.api_root + "/paypal/callbacks"
        self.gateway_details = {}
        self.config = config
        self.cart_shipping_method = cart.shipping_method
        self.shipping_method = cart_shipping_method || shipping_methods.first
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
                         shipping_options: shipping_options,
                         shipping: convert_amount(shipping_method.price),
                         subtotal: convert_amount(cart.total - (cart_shipping_method ? cart_shipping_method.price : 0) - cart.tax), # As the cart total wont include any shipping if it has no shipping method
                         handling: convert_amount(0.0),
                         tax: convert_amount(cart.tax),
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
        if allow_shipping_change
          paypal_params.merge! callback_url: callback_url, callback_timeout: 6, callback_version: 95, max_amount: convert_amount((cart.total * 1.2) + shipping_methods.last.price + shipping_methods.last.tax)
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
        update_cart_if_required(cart: cart, token: token)
        response = gateway.purchase(convert_amount(cart.total), token: token, payer_id: payer_id, currency: ::ShiftCommerce::UiPaymentGateway::DEFAULT_CURRENCY)
        raise Exceptions::PaymentNotAccepted.new(response) unless response.success?
        return response.params
      end

      def get_shipping_address_attributes(token:)
        details = gateway_details_for(token)
        convert_address_service.call(details.params["PaymentDetails"]["ShipToAddress"])
      end

      def get_billing_address_attributes(token:)
        details = gateway_details_for(token)
        convert_address_service.call(details.params["PayerInfo"]["Address"])
      end

      def get_email_address(token:)
        details = gateway_details_for(token)
        details.params["PayerInfo"]["Payer"]
      end

      private

      def update_cart_if_required(cart:, token:)
        cart_shipping_method_id = cart.shipping_method.try(:id)
        details = gateway_details_for(token)
        shipping_method = shipping_methods.detect {|sm| sm.label == details.params["shipping_option_name"]}
        raise "Shipping method not found" unless shipping_method
        cart.update_attributes shipping_method_id: shipping_method.id unless  shipping_method.id == cart_shipping_method_id
      end

      def gateway_details_for(token)
        gateway_details[token] ||= gateway.details_for(token)
      end

      def shipping_methods
        @shipping_methods ||= shipping_method_model.all.sort {|a, b| a.price <=> b.price }
      end

      def shipping_method_model
        config.shipping_method_model.constantize
      end
      def shipping_options
        shipping_method_id = shipping_method.id
        shipping_methods.map {|sm| {name: sm.label, amount: convert_amount(sm.price), default: sm.id == shipping_method_id, label: sm.description}}
      end

      def get_details_from_paypal?
        !cart_has_addresses
      end


      def convert_amount(amount)
        (amount * 100).round
      end

      attr_accessor :cart, :gateway, :request, :success_url, :cancel_url, :cart_has_addresses, :convert_address_service, :allow_shipping_change, :callback_url, :gateway_details, :config, :shipping_method, :cart_shipping_method
    end
  end
end