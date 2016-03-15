module ShiftCommerce
  module UiPaymentGateway
    module Paypal
      # Populates the cart from paypal detail params which look like this
      # payment_details looks like this
      #   {
      #         "OrderTotal" => "582.44",
      #         "ShippingTotal" => "0.00",
      #         "HandlingTotal" => "0.00",
      #         "TaxTotal" => "0.00",
      #         "OrderDescription" => "THE DEFAULT DESCRIPTION - TO BE CHANGED",
      #         "ShipToAddress" => {
      #             "Name" => "Gary Taylor",
      #             "Street1" => "Addr 1",
      #             "Street2" => nil,
      #             "CityName" => "Town",
      #             "StateOrProvince" => "Derbyshire",
      #             "Country" => "GB",
      #             "CountryName" => "United Kingdom",
      #             "Phone" => nil,
      #             "PostalCode" => "DE110BH",
      #             "AddressID" => nil,
      #             "AddressOwner" => "PayPal",
      #             "ExternalAddressID" => nil,
      #             "AddressStatus" => "Confirmed",
      #             "AddressNormalizationStatus" => "None"
      #         },
      #         "InsuranceTotal" => "0.00",
      #         "ShippingDiscount" => "0.00",
      #         "InsuranceOptionOffered" => "false",
      #         "SellerDetails" => {
      #             "PayPalAccountID" => "gary.taylor@flexcommerce.com"
      #         },
      #         "TransactionId" => "95F107665K256243L",
      #         "PaymentRequestID" => nil,
      #         "OrderURL" => nil,
      #         "SoftDescriptor" => nil
      # }
      #
      # payer_details looks like this
      #
      #   {
      #         "Payer" => "gary.taylor@hismessages.com",
      #         "PayerID" => "C8RLYLMQUK7WG",
      #         "PayerStatus" => "verified",
      #         "PayerName" => {
      #             "Salutation" => nil,
      #             "FirstName" => "Gary",
      #             "MiddleName" => nil,
      #             "LastName" => "Taylor",
      #             "Suffix" => nil
      #         },
      #         "PayerCountry" => "GB",
      #         "PayerBusiness" => nil,
      #         "Address" => {
      #             "Name" => "Gary Taylor",
      #             "Street1" => "Addr 1",
      #             "Street2" => nil,
      #             "CityName" => "Town",
      #             "StateOrProvince" => "Derbyshire",
      #             "Country" => "GB",
      #             "CountryName" => "United Kingdom",
      #             "PostalCode" => "DE110BH",
      #             "AddressOwner" => "PayPal",
      #             "AddressStatus" => "Confirmed"
      #         }
      #
      #   }


    class PopulateCart
        def self.call(*args)
          new.call(*args)
        end

        def call(payment_details:, payer_details:, cart:)
          debug_me
        end

      end
    end
  end
end