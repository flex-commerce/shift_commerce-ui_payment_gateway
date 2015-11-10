module ShiftCommerce
  module UiPaymentGateway
    class PaymentService
      def initialize(engine: :paypal, controller: :transactions, order:, request:, success_url:, cancel_url:)
        self.engine = engine_for(engine).new(order: order, request: request, success_url: success_url, cancel_url: cancel_url)
        self.controller = controller
      end

      delegate :setup_payment, to: :engine

      private

      attr_accessor :engine, :controller

      def engine_for(engine)
        "::ShiftCommerce::UiPaymentGateway::#{engine.to_s.camelize}Engine".constantize
      end
    end
  end
end