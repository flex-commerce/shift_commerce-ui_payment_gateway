require_relative "./base"
module ShiftCommerce
  module UiPaymentGateway
    module Exceptions
      class PaymentNotAccepted < Base
        attr_accessor :response
        def initialize(response)
          self.response = response
        end

        def message
          "PaymentNotAccepted Exception - #{response.message} \n\n#{response.params.to_json}"
        end

      end
    end
  end
end