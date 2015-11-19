require "active_support/concern"
module ShiftCommerce
  module UiPaymentGateway
    module ControllerExtensions

      def order_model
        ::ShiftCommerce::UiPaymentGateway::Config.instance.order_model.constantize
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
          transaction_type: "paypal_express",
          status: "success"
        }
        order = order_model.create(cart_id: cart.id, transaction_attributes: txn )
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
                                                                                     success_url: url_for(action: :new_with_token, only_path: true),
                                                                                     cancel_url: url_for(action: :new, only_path: true).gsub(/\/transactions\/new$/, ''),
                                                                                     controller: self.class.name.gsub(/Controller$/, '').underscore.to_sym
        end
      end

    end
  end
end