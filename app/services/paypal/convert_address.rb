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
      #             "Name" => "First Middle1 Middle2 Last",
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
      #             "Name" => "First Middle1 Middle2 Last",
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


      class ConvertAddress
        def self.call(*args)
          new.call(*args)
        end

        def call(address)
          to_address_attrs(address)
        end

        private

        def to_address_attrs(paypal_address)
          mapping = direct_mapping
          name_words = paypal_address["Name"].split(" ")
          attrs = {
            "first_name" => name_words.shift,
            "last_name" => name_words.pop || "",
            "middle_names" => name_words.join(" ")
          }
          paypal_address.inject(attrs) do |acc, (field, value)|
            if mapping.key?(field)
              acc.merge(mapping[field] => value || "")
            else
              acc
            end
          end
        end

        def direct_mapping
          {
            "Street1" => "address_line_1",
            "Street2" => "address_line_2",
            "CityName" => "city",
            "StateOrProvince" => "state",
            "Country" => "country",
            "PostalCode" => "postcode"
          }
        end

      end
    end
  end
end