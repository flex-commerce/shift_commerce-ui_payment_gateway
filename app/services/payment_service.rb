module ShiftCommerce
  module UiPaymentGateway
    class PaymentService
      def initialize(engine: :paypal, controller: :transactions, cart:, request:, success_url:, cancel_url:, **options)
        self.engine = engine_for(engine).new(cart: cart, request: request, success_url: success_url, cancel_url: cancel_url, **options)
        self.controller = controller
      end

      delegate :setup_payment, :process_token, :get_shipping_address_attributes, :get_billing_address_attributes, :get_email_address, to: :engine

      private

      attr_accessor :engine, :controller

      def engine_for(engine)
        "::ShiftCommerce::UiPaymentGateway::#{engine.to_s.camelize}Engine".constantize
      end
    end
  end
end