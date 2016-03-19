require "active_support/concern"
module ShiftCommerce
  module UiPaymentGateway
    module ControllerExtensions

      def order_model
        ::ShiftCommerce::UiPaymentGateway::Config.instance.order_model.constantize
      end

      def address_model
        ::ShiftCommerce::UiPaymentGateway::Config.instance.address_model.constantize
      end

      def new_with_gateway
        redirect_to payment_service.setup_payment(cart: cart)
      end

      def new
        self.page_title = I18n.t("transactions.new.page_title")
      end

      def new_with_token
        gateway_response = payment_service.process_token(token: params[:token], cart: cart, payer_id: params[:PayerID])
        txn = {
          gateway_response: gateway_response,
          amount: cart.total,
          currency: ::ShiftCommerce::UiPaymentGateway::DEFAULT_CURRENCY,
          transaction_type: "settlement",
          payment_gateway_reference: "paypal_express",
          status: "success",
        }
        cart_needs_save = false
        if cart.shipping_address.nil?
          cart.shipping_address_id = address_model.create!(payment_service.get_shipping_address_attributes(token: params[:token])).id
          cart.billing_address_id = address_model.create!(payment_service.get_billing_address_attributes(token: params[:token])).id
          cart_needs_save = true
        end
        unless cart.email.present?
          cart.email = payment_service.get_email_address(token: params[:token])
          cart_needs_save = true
        end
        cart.save! if cart_needs_save
        order = order_model.create!(cart_id: cart.id, transaction_attributes: txn, order_ip_address: request.ip )
        on_order_created(order)
      end

      def on_order_created(order)
        redirect_to action: :show, id: order.id, controller: ::ShiftCommerce::UiPaymentGateway::Config.instance.order_model.underscore.pluralize

      end

      private

      def cart
        send(Config.instance.current_cart_method)
      end

      def payment_service
        if params[:gateway] == "paypal"
          @payment_service ||= ::ShiftCommerce::UiPaymentGateway::PaymentService.new engine: :paypal_express,
                                                                                     cart: cart,
                                                                                     request: request,
                                                                                     success_url: success_url,
                                                                                     cancel_url: cancel_url,
                                                                                     controller: self.class.name.gsub(/Controller$/, '').underscore.to_sym,
                                                                                     allow_shipping_change: true
        end
      end

      def success_url
        url_for(action: :new_with_token)
      end

      def cancel_url
        url_for(action: :new).gsub(/\/transactions\/new$/, '')
      end

    end
  end
end
