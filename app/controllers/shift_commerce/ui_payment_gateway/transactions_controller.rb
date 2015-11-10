module ShiftCommerce
  module UiPaymentGateway
    class TransactionsController < ApplicationController
      attr_accessor :page_title
      helper_attr :page_title


      OrderModel = Config.instance.order_model.constantize
      extend ActiveSupport::Concern

      def new_with_gateway
        redirect_to payment_service.setup_payment(order: order)
      end

      def new
        self.page_title = I18n.t("ui_payment_gateway.transactions.new.page_title")
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