require "active_support/concern"
module ShiftCommerce
  module UiPaymentGateway
    module ControllerExtensions
      def new_with_gateway
        redirect_to payment_service.setup_payment(cart: cart)
      end

      def new
        self.page_title = I18n.t("transactions.new.page_title")
      end

      def new_with_token
        payment_service.process_token(token: params[:token], cart: cart, payer_id: params[:PayerID])
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
                                                                                     success_url: url_for(action: :new_with_token),
                                                                                     cancel_url: url_for(action: :new).gsub(/\/transactions\/new$/, ''),
                                                                                     controller: self.class.name.gsub(/Controller$/, '').underscore.to_sym
        end
      end

    end
  end
end