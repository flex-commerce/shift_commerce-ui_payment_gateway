require_relative "./base"
module ShiftCommerce
  module UiPaymentGateway
    module Exceptions
      class PaymentNotAccepted < Base
        attr_accessor :response
        def initialize(response)
          self.response = response
        end

      end
    end
  end
end