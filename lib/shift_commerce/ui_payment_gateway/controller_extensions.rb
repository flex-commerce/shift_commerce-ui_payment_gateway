require "active_support/concern"
module ShiftCommerce
  module UiPaymentGateway
    module ControllerExtensions
      CartModel = ::Cart
      extend ActiveSupport::Concern

      def new
        redirect_to payment_service.setup_payment(cart: cart)
      end

      private

      def cart
        CartModel.find(params[:cart_id])
      end

      def payment_service
        @payment_service ||= ::ShiftCommerce::UiPaymentGateway::PaymentService.new engine: :paypal_express,
                                                                                   cart: cart,
                                                                                   request: request,
                                                                                   success_url: url_for(action: :new_with_token),
                                                                                   cancel_url: url_for(action: :show, controller: :carts, id: params[:cart_id]),
                                                                                   controller: self.class.name.gsub(/Controller$/, '').underscore.to_sym
      end
    end
  end
end