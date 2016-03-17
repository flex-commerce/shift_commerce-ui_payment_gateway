require "rails_helper"
RSpec.describe "transaction request specs", type: :request, vcr: {record: :once} do
  let(:base_url) { "http://www.example.com" }
  let(:currency) { ::ShiftCommerce::UiPaymentGateway::DEFAULT_CURRENCY }
  context "when paypal is the payment engine" do
    context "stage 1 - capturing" do
      it "should redirect to paypal when a new transaction is started" do
        get "/cart/transactions/new/paypal"
        expect(response).to redirect_to /https:\/\/www.sandbox.paypal.com\/cgi-bin\/webscr\?cmd=_express-checkout&token=.+$/
      end
      context "with mocked paypal" do
        let(:dummy_paypal_response) do
          <<-EOS
        <?xml version="1.0" encoding="UTF-8"?><SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"
        xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:cc="urn:ebay:apis:CoreComponentTypes" xmlns:wsu="http://schemas.xmlsoap.org/ws/2002/07/utility"
        xmlns:saml="urn:oasis:names:tc:SAML:1.0:assertion" xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
        xmlns:wsse="http://schemas.xmlsoap.org/ws/2002/12/secext" xmlns:ed="urn:ebay:apis:EnhancedDataTypes"
        xmlns:ebl="urn:ebay:apis:eBLBaseComponents" xmlns:ns="urn:ebay:api:PayPalAPI"><SOAP-ENV:Header><Security
        xmlns="http://schemas.xmlsoap.org/ws/2002/12/secext" xsi:type="wsse:SecurityType"></Security><RequesterCredentials
        xmlns="urn:ebay:api:PayPalAPI" xsi:type="ebl:CustomSecurityHeaderType"><Credentials
        xmlns="urn:ebay:apis:eBLBaseComponents" xsi:type="ebl:UserIdPasswordType"><Username
        xsi:type="xs:string"></Username><Password xsi:type="xs:string"></Password><Signature
        xsi:type="xs:string"></Signature><Subject xsi:type="xs:string"></Subject></Credentials></RequesterCredentials></SOAP-ENV:Header><SOAP-ENV:Body
        id="_0"><SetExpressCheckoutResponse xmlns="urn:ebay:api:PayPalAPI"><Timestamp
        xmlns="urn:ebay:apis:eBLBaseComponents">2015-11-17T14:14:42Z</Timestamp><Ack
        xmlns="urn:ebay:apis:eBLBaseComponents">Success</Ack><CorrelationID xmlns="urn:ebay:apis:eBLBaseComponents">817fb68526a17</CorrelationID><Version
        xmlns="urn:ebay:apis:eBLBaseComponents">124</Version><Build xmlns="urn:ebay:apis:eBLBaseComponents">18308778</Build><Token
        xsi:type="ebl:ExpressCheckoutTokenType">EC-7S574538S90932332</Token></SetExpressCheckoutResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>
          EOS
        end
        let!(:stub) { stub_request(:post, /https:\/\/.*\.sandbox\.paypal\.com/).to_return(body: dummy_paypal_response) }
        it "should send the correct amount to paypal" do
          get "/cart/transactions/new/paypal"
          expect(stub.with(body: %r(<n2:OrderTotal currencyID="#{currency}">40\.00<\/n2:OrderTotal>))).to have_been_requested
        end

        context "when the applications cart has a shipping address" do
          it "should send the correct urls to paypal" do
            get "/cart/transactions/new/paypal"
            expect(stub.with(body: %r(<n2:ReturnURL>#{base_url}/cart/transactions/new_with_token/paypal</n2:ReturnURL>))).to have_been_requested
            expect(stub.with(body: %r(<n2:CancelURL>#{base_url}/cart</n2:CancelURL>))).to have_been_requested

          end

          it "should send the shipping address to paypal" do
            get "/cart/transactions/new/paypal"
            expect(stub.with(body: /<n2:ShipToAddress>.*<\/n2:ShipToAddress>/m)).to have_been_requested
            expect(stub.with(body: %r(<n2:Name>first middle last</n2:Name>))).to have_been_requested
            expect(stub.with(body: %r(<n2:Street1>shipping address 1</n2:Street1>))).to have_been_requested
            expect(stub.with(body: %r(<n2:Street2>shipping address 2</n2:Street2>))).to have_been_requested
            expect(stub.with(body: %r(<n2:CityName>shipping address city</n2:CityName>))).to have_been_requested
            expect(stub.with(body: %r(<n2:StateOrProvince>shipping address state</n2:StateOrProvince>))).to have_been_requested
            expect(stub.with(body: %r(<n2:Country>GB</n2:Country>))).to have_been_requested
            expect(stub.with(body: %r(<n2:PostalCode>shipping postcode</n2:PostalCode>))).to have_been_requested
          end

          it "should override the address with ours" do
            get "/cart/transactions/new/paypal"
            expect(stub.with(body: %r(<n2:AddressOverride>1</n2:AddressOverride>))).to have_been_requested
          end

        end

        context "when the application cart does not have a shipping address", env_vars: {"NO_SHIPPING_ADDRESS" => "1"} do
          it "should send the correct urls to paypal" do
            get "/cart/transactions/new/paypal"
            expect(stub.with(body: %r(<n2:ReturnURL>#{base_url}/cart/transactions/new_with_token/paypal</n2:ReturnURL>))).to have_been_requested
            expect(stub.with(body: %r(<n2:CancelURL>#{base_url}/cart</n2:CancelURL>))).to have_been_requested

          end

          it "should not send the shipping address to paypal" do
            get "/cart/transactions/new/paypal"
            expect(stub.with(body: /<n2:ShipToAddress>.*<\/n2:ShipToAddress>/m)).not_to have_been_requested
            expect(stub.with(body: %r(<n2:Name>first middle last</n2:Name>))).not_to have_been_requested
            expect(stub.with(body: %r(<n2:Street1>shipping address 1</n2:Street1>))).not_to have_been_requested
            expect(stub.with(body: %r(<n2:Street2>shipping address 2</n2:Street2>))).not_to have_been_requested
            expect(stub.with(body: %r(<n2:CityName>shipping address city</n2:CityName>))).not_to have_been_requested
            expect(stub.with(body: %r(<n2:StateOrProvince>shipping address state</n2:StateOrProvince>))).not_to have_been_requested
            expect(stub.with(body: %r(<n2:Country>GB</n2:Country>))).not_to have_been_requested
            expect(stub.with(body: %r(<n2:PostalCode>shipping postcode</n2:PostalCode>))).not_to have_been_requested
          end

          it "should override the address with ours" do
            get "/cart/transactions/new/paypal"
            expect(stub.with(body: %r(<n2:AddressOverride>1</n2:AddressOverride>))).not_to have_been_requested
          end

        end

        it "should send the line items to paypal" do
          get "/cart/transactions/new/paypal"
          expect(stub.with(body: %r(<n2:Name>Line item 1 name<\/n2:Name>))).to have_been_requested
        end

      end

    end
    context "stage 2 - success callback" do
      context "with mocked paypal" do
        let(:dummy_paypal_response) do
          <<-EOS
<?xml version="1.0" encoding="UTF-8"?>
<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"
                   xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/"
                   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                   xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:cc="urn:ebay:apis:CoreComponentTypes"
                   xmlns:wsu="http://schemas.xmlsoap.org/ws/2002/07/utility"
                   xmlns:saml="urn:oasis:names:tc:SAML:1.0:assertion" xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
                   xmlns:wsse="http://schemas.xmlsoap.org/ws/2002/12/secext" xmlns:ed="urn:ebay:apis:EnhancedDataTypes"
                   xmlns:ebl="urn:ebay:apis:eBLBaseComponents" xmlns:ns="urn:ebay:api:PayPalAPI">
  <SOAP-ENV:Header>
    <Security xmlns="http://schemas.xmlsoap.org/ws/2002/12/secext" xsi:type="wsse:SecurityType"></Security>
    <RequesterCredentials xmlns="urn:ebay:api:PayPalAPI" xsi:type="ebl:CustomSecurityHeaderType">
      <Credentials xmlns="urn:ebay:apis:eBLBaseComponents" xsi:type="ebl:UserIdPasswordType">
        <Username xsi:type="xs:string"></Username>
        <Password xsi:type="xs:string"></Password>
        <Signature xsi:type="xs:string"></Signature>
        <Subject xsi:type="xs:string"></Subject>
      </Credentials>
    </RequesterCredentials>
  </SOAP-ENV:Header>
  <SOAP-ENV:Body id="_0">
    <DoExpressCheckoutPaymentResponse xmlns="urn:ebay:api:PayPalAPI">
      <Timestamp xmlns="urn:ebay:apis:eBLBaseComponents">2015-11-18T09:19:30Z</Timestamp>
      <Ack xmlns="urn:ebay:apis:eBLBaseComponents">Success</Ack>
      <CorrelationID xmlns="urn:ebay:apis:eBLBaseComponents">f2c9e5afa6977</CorrelationID>
      <Version xmlns="urn:ebay:apis:eBLBaseComponents">124</Version>
      <Build xmlns="urn:ebay:apis:eBLBaseComponents">18308778</Build>
      <DoExpressCheckoutPaymentResponseDetails xmlns="urn:ebay:apis:eBLBaseComponents"
                                               xsi:type="ebl:DoExpressCheckoutPaymentResponseDetailsType">
        <Token xsi:type="ebl:ExpressCheckoutTokenType">EC-0L085039R20178634</Token>
        <PaymentInfo xsi:type="ebl:PaymentInfoType">
          <TransactionID>6JH338372S307180T</TransactionID>
          <ParentTransactionID xsi:type="ebl:TransactionId"></ParentTransactionID>
          <ReceiptID></ReceiptID>
          <TransactionType xsi:type="ebl:PaymentTransactionCodeType">express-checkout</TransactionType>
          <PaymentType xsi:type="ebl:PaymentCodeType">instant</PaymentType>
          <PaymentDate xsi:type="xs:dateTime">2015-11-18T09:19:29Z</PaymentDate>
          <GrossAmount xsi:type="cc:BasicAmountType" currencyID="GBP">520.13</GrossAmount>
          <FeeAmount xsi:type="cc:BasicAmountType" currencyID="GBP">17.88</FeeAmount>
          <TaxAmount xsi:type="cc:BasicAmountType" currencyID="GBP">0.00</TaxAmount>
          <ExchangeRate xsi:type="xs:string"></ExchangeRate>
          <PaymentStatus xsi:type="ebl:PaymentStatusCodeType">Completed</PaymentStatus>
          <PendingReason xsi:type="ebl:PendingStatusCodeType">none</PendingReason>
          <ReasonCode xsi:type="ebl:ReversalReasonCodeType">none</ReasonCode>
          <ProtectionEligibility xsi:type="xs:string">Eligible</ProtectionEligibility>
          <ProtectionEligibilityType xsi:type="xs:string">ItemNotReceivedEligible,UnauthorizedPaymentEligible
          </ProtectionEligibilityType>
          <SellerDetails xsi:type="ebl:SellerDetailsType">
            <SecureMerchantAccountID xsi:type="ebl:UserIDType">ZB5ZKU4VGX8HJ</SecureMerchantAccountID>
          </SellerDetails>
        </PaymentInfo>
        <SuccessPageRedirectRequested xsi:type="xs:string">false</SuccessPageRedirectRequested>
        <CoupledPaymentInfo xsi:type="ebl:CoupledPaymentInfoType"></CoupledPaymentInfo>
      </DoExpressCheckoutPaymentResponseDetails>
    </DoExpressCheckoutPaymentResponse>
  </SOAP-ENV:Body>
</SOAP-ENV:Envelope>
          EOS
        end
        let!(:stub) { stub_request(:post, /https:\/\/.*\.sandbox\.paypal\.com/).to_return(body: dummy_paypal_response) }
        let(:dummy_paypal_details_response) do
          <<-EOS
<?xml version="1.0" encoding="UTF-8"?>
<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"
                   xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/"
                   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                   xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:cc="urn:ebay:apis:CoreComponentTypes"
                   xmlns:wsu="http://schemas.xmlsoap.org/ws/2002/07/utility"
                   xmlns:saml="urn:oasis:names:tc:SAML:1.0:assertion" xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
                   xmlns:wsse="http://schemas.xmlsoap.org/ws/2002/12/secext" xmlns:ed="urn:ebay:apis:EnhancedDataTypes"
                   xmlns:ebl="urn:ebay:apis:eBLBaseComponents" xmlns:ns="urn:ebay:api:PayPalAPI">
  <SOAP-ENV:Header>
    <Security xmlns="http://schemas.xmlsoap.org/ws/2002/12/secext" xsi:type="wsse:SecurityType"></Security>
    <RequesterCredentials xmlns="urn:ebay:api:PayPalAPI" xsi:type="ebl:CustomSecurityHeaderType">
      <Credentials xmlns="urn:ebay:apis:eBLBaseComponents" xsi:type="ebl:UserIdPasswordType">
        <Username xsi:type="xs:string"></Username>
        <Password xsi:type="xs:string"></Password>
        <Signature xsi:type="xs:string"></Signature>
        <Subject xsi:type="xs:string"></Subject>
      </Credentials>
    </RequesterCredentials>
  </SOAP-ENV:Header>
  <SOAP-ENV:Body id="_0">
    <GetExpressCheckoutDetailsResponse xmlns="urn:ebay:api:PayPalAPI">
      <Timestamp xmlns="urn:ebay:apis:eBLBaseComponents">2016-03-16T09:25:15Z</Timestamp>
      <Ack xmlns="urn:ebay:apis:eBLBaseComponents">Success</Ack>
      <CorrelationID xmlns="urn:ebay:apis:eBLBaseComponents">5a8d2e95165cb</CorrelationID>
      <Version xmlns="urn:ebay:apis:eBLBaseComponents">124</Version>
      <Build xmlns="urn:ebay:apis:eBLBaseComponents">18316154</Build>
      <GetExpressCheckoutDetailsResponseDetails xmlns="urn:ebay:apis:eBLBaseComponents"
                                                xsi:type="ebl:GetExpressCheckoutDetailsResponseDetailsType">
        <Token xsi:type="ebl:ExpressCheckoutTokenType">EC-2108354910690160N</Token>
        <PayerInfo xsi:type="ebl:PayerInfoType">
          <Payer xsi:type="ebl:EmailAddressType">ryan+paypal-buyer@flexcommerce.com</Payer>
          <PayerID xsi:type="ebl:UserIDType">KDW6SJUJWEW3E</PayerID>
          <PayerStatus xsi:type="ebl:PayPalUserStatusCodeType">verified</PayerStatus>
          <PayerName xsi:type="ebl:PersonNameType">
            <Salutation xmlns="urn:ebay:apis:eBLBaseComponents"></Salutation>
            <FirstName xmlns="urn:ebay:apis:eBLBaseComponents">test</FirstName>
            <MiddleName xmlns="urn:ebay:apis:eBLBaseComponents"></MiddleName>
            <LastName xmlns="urn:ebay:apis:eBLBaseComponents">buyer</LastName>
            <Suffix xmlns="urn:ebay:apis:eBLBaseComponents"></Suffix>
          </PayerName>
          <PayerCountry xsi:type="ebl:CountryCodeType">GB</PayerCountry>
          <PayerBusiness xsi:type="xs:string"></PayerBusiness>
          <Address xsi:type="ebl:AddressType">
            <Name xsi:type="xs:string">Billing Middle1 Middle2 Name</Name>
            <Street1 xsi:type="xs:string">Billing Address Line 1</Street1>
            <Street2 xsi:type="xs:string">Billing Address Line 2</Street2>
            <CityName xsi:type="xs:string">Billing City</CityName>
            <StateOrProvince xsi:type="xs:string">Billing State</StateOrProvince>
            <Country xsi:type="ebl:CountryCodeType">GB</Country>
            <CountryName>United Kingdom</CountryName>
            <PostalCode xsi:type="xs:string">Billing Post Code</PostalCode>
            <AddressOwner xsi:type="ebl:AddressOwnerCodeType">PayPal</AddressOwner>
            <AddressStatus xsi:type="ebl:AddressStatusCodeType">Confirmed</AddressStatus>
          </Address>
        </PayerInfo>
        <ContactPhone xsi:type="xs:string">035-287-8596</ContactPhone>
        <BillingAgreementAcceptedStatus>false</BillingAgreementAcceptedStatus>
        <PaymentDetails xsi:type="ebl:PaymentDetailsType">
          <OrderTotal xsi:type="cc:BasicAmountType" currencyID="GBP">354.31</OrderTotal>
          <ShippingTotal xsi:type="cc:BasicAmountType" currencyID="GBP">0.00</ShippingTotal>
          <HandlingTotal xsi:type="cc:BasicAmountType" currencyID="GBP">0.00</HandlingTotal>
          <TaxTotal xsi:type="cc:BasicAmountType" currencyID="GBP">0.00</TaxTotal>
          <OrderDescription xsi:type="xs:string">THE DEFAULT DESCRIPTION - TO BE CHANGED</OrderDescription>
          <ShipToAddress xsi:type="ebl:AddressType">
            <Name xsi:type="xs:string">Shipping Middle1 Middle2 Name</Name>
            <Street1 xsi:type="xs:string">Shipping Address Line 1</Street1>
            <Street2 xsi:type="xs:string">Shipping Address Line 2</Street2>
            <CityName xsi:type="xs:string">Shipping City</CityName>
            <StateOrProvince xsi:type="xs:string">Shipping State</StateOrProvince>
            <Country xsi:type="ebl:CountryCodeType">GB</Country>
            <CountryName>United Kingdom</CountryName>
            <Phone xsi:type="xs:string"></Phone>
            <PostalCode xsi:type="xs:string">Shipping Post Code</PostalCode>
            <AddressID xsi:type="xs:string"></AddressID>
            <AddressOwner xsi:type="ebl:AddressOwnerCodeType">PayPal</AddressOwner>
            <ExternalAddressID xsi:type="xs:string"></ExternalAddressID>
            <AddressStatus xsi:type="ebl:AddressStatusCodeType">Confirmed</AddressStatus>
            <AddressNormalizationStatus xsi:type="ebl:AddressNormalizationStatusCodeType">None
            </AddressNormalizationStatus>
          </ShipToAddress>
          <InsuranceTotal xsi:type="cc:BasicAmountType" currencyID="GBP">0.00</InsuranceTotal>
          <ShippingDiscount xsi:type="cc:BasicAmountType" currencyID="GBP">0.00</ShippingDiscount>
          <InsuranceOptionOffered xsi:type="xs:string">false</InsuranceOptionOffered>
          <SellerDetails xsi:type="ebl:SellerDetailsType">
            <PayPalAccountID xsi:type="xs:string">ryan+paypal-facilitator@flexcommerce.com</PayPalAccountID>
          </SellerDetails>
          <TransactionId xsi:type="xs:string">1HF06200YB1257708</TransactionId>
          <PaymentRequestID xsi:type="xs:string"></PaymentRequestID>
          <OrderURL xsi:type="xs:string"></OrderURL>
          <SoftDescriptor xsi:type="xs:string"></SoftDescriptor>
        </PaymentDetails>
        <CheckoutStatus xsi:type="xs:string">PaymentActionCompleted</CheckoutStatus>
        <PaymentRequestInfo xsi:type="ebl:PaymentRequestInfoType">
          <TransactionId xsi:type="xs:string">1HF06200YB1257708</TransactionId>
        </PaymentRequestInfo>
        <PaymentInfo xsi:type="ebl:PaymentInfoType">
          <TransactionID></TransactionID>
          <ParentTransactionID xsi:type="ebl:TransactionId"></ParentTransactionID>
          <ReceiptID></ReceiptID>
          <TransactionType xsi:type="ebl:PaymentTransactionCodeType">none</TransactionType>
          <PaymentType xsi:type="ebl:PaymentCodeType">none</PaymentType>
          <ExchangeRate xsi:type="xs:string"></ExchangeRate>
          <PaymentStatus xsi:type="ebl:PaymentStatusCodeType">None</PaymentStatus>
          <PendingReason xsi:type="ebl:PendingStatusCodeType">none</PendingReason>
          <ReasonCode xsi:type="ebl:ReversalReasonCodeType">none</ReasonCode>
          <SellerDetails xsi:type="ebl:SellerDetailsType"></SellerDetails>
        </PaymentInfo>
        <CartChangeTolerance xsi:type="xs:string"></CartChangeTolerance>
      </GetExpressCheckoutDetailsResponseDetails>
    </GetExpressCheckoutDetailsResponse>
  </SOAP-ENV:Body>
</SOAP-ENV:Envelope>
          EOS
        end
        let!(:paypal_details_stub) do
          stub_request(:post, /https:\/\/.*\.sandbox\.paypal\.com/).with(body: /GetExpressCheckoutDetailsReq/).to_return(body: dummy_paypal_details_response)
        end
        context "when the application cart has a shipping address" do
          it "should complete the transaction with paypal" do
            get "/cart/transactions/new_with_token/paypal?token=SOMERANDOMTOKEN&PayerID=SOMERANDOMPAYERID"
            expect(stub.with(body: %r(<n2:Token>SOMERANDOMTOKEN</n2:Token>))).to have_been_requested
            expect(stub.with(body: %r(<n2:PayerID>SOMERANDOMPAYERID</n2:PayerID>))).to have_been_requested
            expect(response).to redirect_to(/orders\/[^\/]*$/)
          end
        end
        context "when the application cart does not have a shipping address", env_vars: {"NO_SHIPPING_ADDRESS" => "1"} do
          it "should complete the transaction with paypal" do
            create_shipping_args = {
              "first_name" => "Shipping",
              "middle_names" => "Middle1 Middle2",
              "last_name" => "Name",
              "address_line_1" => "Shipping Address Line 1",
              "address_line_2" => "Shipping Address Line 2",
              "city" => "Shipping City",
              "state" => "Shipping State",
              "postcode" => "Shipping Post Code",
              "country" => "GB"
            }
            create_billing_args = {
              "first_name" => "Billing",
              "middle_names" => "Middle1 Middle2",
              "last_name" => "Name",
              "address_line_1" => "Billing Address Line 1",
              "address_line_2" => "Billing Address Line 2",
              "city" => "Billing City",
              "state" => "Billing State",
              "postcode" => "Billing Post Code",
              "country" => "GB"
            }
            expect(Address).to receive(:create!).with(hash_including create_shipping_args).once.and_return Address.new(id: 1)
            expect(Address).to receive(:create!).with(hash_including  create_billing_args).once.and_return Address.new(id: 2)
            expect_any_instance_of(Cart).to receive(:shipping_address_id=).once
            expect_any_instance_of(Cart).to receive(:billing_address_id=).once
            get "/cart/transactions/new_with_token/paypal?token=SOMERANDOMTOKEN&PayerID=SOMERANDOMPAYERID"
            expect(stub.with(body: %r(<n2:Token>SOMERANDOMTOKEN</n2:Token>))).to have_been_requested
            expect(stub.with(body: %r(<n2:PayerID>SOMERANDOMPAYERID</n2:PayerID>))).to have_been_requested
            expect(response).to redirect_to(/orders\/[^\/]*$/)
          end

        end

      end
    end
  end
end