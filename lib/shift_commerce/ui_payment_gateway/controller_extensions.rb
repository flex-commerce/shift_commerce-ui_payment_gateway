require "active_support/concern"
module ShiftCommerce
  module UiPaymentGateway
    module ControllerExtensions
      OrderModel = Config.instance.order_model.constantize
      def new_with_gateway
        redirect_to payment_service.setup_payment(order: order)
      end

      def new
        self.page_title = I18n.t("transactions.new.page_title")
      end

      private

      def order
        OrderModel.find(params[:order_id])
      end

      def payment_service
        if params[:gateway] == "paypal"
          @payment_service ||= ::ShiftCommerce::UiPaymentGateway::PaymentService.new engine: :paypal_express,
                                                                                     order: order,
                                                                                     request: request,
                                                                                     success_url: url_for(action: :new_with_token),
                                                                                     cancel_url: url_for(action: :new).gsub(/\/transactions\/new$/, ''),
                                                                                     controller: self.class.name.gsub(/Controller$/, '').underscore.to_sym
        end
      end

    end
  end
end