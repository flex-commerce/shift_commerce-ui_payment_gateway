require "active_support/concern"
module ShiftCommerce
  module UiPaymentGateway
    module ControllerExtensions

      def order_model
        ::ShiftCommerce::UiPaymentGateway::Config.instance.order_model.constantize
      end

      def new_with_gateway
        setup = ::FlexCommerce::PaymentProviderSetup.create(cart_id: cart.id, payment_provider_id: "reference:paypal_express", success_url: success_url, cancel_url: cancel_url, ip_address: request.remote_ip, allow_shipping_change: allow_shipping_method_change, use_mobile_payments: use_mobile_payments)
        if setup.persisted?
          redirect_to setup.redirect_url
        else
          # @TODO Better error reporting here
          raise "Setup not completed correctly"
        end
      end

      def new
        self.page_title = I18n.t("transactions.new.page_title")
      end

      def new_with_token
        order = FlexCommerce::Order.create! cart_id: cart.id, order_ip_address: request.ip, transaction_attributes: { gateway_response: { token: params[:token], payer_id: params[:PayerID] }, amount: cart.total, currency: ::ShiftCommerce::UiPaymentGateway::DEFAULT_CURRENCY, transaction_type: "authorisation", status: "received", payment_gateway_reference: "paypal_express" }
        on_order_created(order)
      end

      def on_order_created(order)
        redirect_to action: :show, id: order.id, controller: ::ShiftCommerce::UiPaymentGateway::Config.instance.order_model.underscore.pluralize

      end

      private

      def cart
        send(Config.instance.current_cart_method)
      end

      def success_url
        url_for(action: :new_with_token)
      end

      def cancel_url
        url_for(action: :new).gsub(/\/transactions\/new$/, '')
      end

      def allow_shipping_method_change
        true
      end

      def use_mobile_payments
        false
      end

    end
  end
end
