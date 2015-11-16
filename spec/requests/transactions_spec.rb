require "rails_helper"
RSpec.describe "transaction request specs", type: :request, vcr: {record: :once} do
  let(:base_url) { "http://www.example.com" }
  let(:currency) { ::ShiftCommerce::UiPaymentGateway::DEFAULT_CURRENCY }
  context "when paypal is the payment engine" do
    it "should redirect to paypal when a new transaction is started" do
      get "/orders/1/transactions/new/paypal"
      expect(response).to redirect_to /https:\/\/www.sandbox.paypal.com\/cgi-bin\/webscr\?cmd=_express-checkout&token=.+$/
    end
    context "with mocked paypal" do
      let(:dummy_paypal_response) do
        <<-EOS
          <?xml version="1.0" encoding="UTF-8"?>
          <env:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <env:Header><RequesterCredentials xmlns="urn:ebay:api:PayPalAPI" xmlns:n1="urn:ebay:apis:eBLBaseComponents" env:mustUnderstand="0"><n1:Credentials><n1:Username>gary.taylor_api1.flexcommerce.com</n1:Username><n1:Password>CXLBLQM64B6AXULK</n1:Password><n1:Subject/><n1:Signature>ALYGfT1J93GLRZF-3Y94ce-Z4UZgAsHIQqBoD5p.DabVWhLPVXkcHJw0</n1:Signature></n1:Credentials></RequesterCredentials></env:Header>
            <env:Body>
              <SetExpressCheckoutReq xmlns="urn:ebay:api:PayPalAPI">
                <SetExpressCheckoutRequest xmlns:n2="urn:ebay:apis:eBLBaseComponents">
                  <n2:Version>124</n2:Version>
                  <n2:SetExpressCheckoutRequestDetails>
                    <n2:ReturnURL>http://mydomain.com/good_url</n2:ReturnURL>
                    <n2:CancelURL>http://mydomain.com/bad_url</n2:CancelURL>
                    <n2:ReqBillingAddress>0</n2:ReqBillingAddress>
                    <n2:NoShipping>0</n2:NoShipping>
                    <n2:AddressOverride>0</n2:AddressOverride>
                    <n2:PaymentDetails>
                      <n2:OrderTotal currencyID="USD">10.00</n2:OrderTotal>
                      <n2:ButtonSource>ActiveMerchant</n2:ButtonSource>
                      <n2:PaymentAction>Sale</n2:PaymentAction>
                    </n2:PaymentDetails>
                  </n2:SetExpressCheckoutRequestDetails>
                </SetExpressCheckoutRequest>
              </SetExpressCheckoutReq>
            </env:Body></env:Envelope>
        EOS
      end
      let!(:stub) { stub_request(:post, /https:\/\/.*\.sandbox\.paypal\.com/).to_return(body: dummy_paypal_response) }
      it "should send the correct amount to paypal" do
        get "/orders/1/transactions/new/paypal"
        expect(stub.with(body: %r(<n2:OrderTotal currencyID="#{currency}">10\.00<\/n2:OrderTotal>))).to have_been_requested
      end

      it "should send the correct urls to paypal" do
        get "/orders/1/transactions/new/paypal"
        expect(stub.with(body: %r(<n2:ReturnURL>#{base_url}/orders/1/transactions/new_with_token</n2:ReturnURL>))).to have_been_requested
        expect(stub.with(body: %r(<n2:CancelURL>#{base_url}/orders/1</n2:CancelURL>))).to have_been_requested

      end

      it "should send the shipping address to paypal" do
        get "/orders/1/transactions/new/paypal"
        expect(stub.with(body: /<n2:ShipToAddress>.*<\/n2:ShipToAddress>/m)).to have_been_requested
        expect(stub.with(body: %r(<n2:Name>shipping name</n2:Name>))).to have_been_requested
        expect(stub.with(body: %r(<n2:Street1>shipping address 1</n2:Street1>))).to have_been_requested
        expect(stub.with(body: %r(<n2:Street2>shipping address 2</n2:Street2>))).to have_been_requested
        expect(stub.with(body: %r(<n2:CityName>shipping address city</n2:CityName>))).to have_been_requested
        expect(stub.with(body: %r(<n2:StateOrProvince>shipping address state</n2:StateOrProvince>))).to have_been_requested
        expect(stub.with(body: %r(<n2:Country>shipping country</n2:Country>))).to have_been_requested
        expect(stub.with(body: %r(<n2:PostalCode>shipping postcode</n2:PostalCode>))).to have_been_requested
      end

      it "should override the address with ours" do
        get "/orders/1/transactions/new/paypal"
        expect(stub.with(body: %r(<n2:AddressOverride>1</n2:AddressOverride>))).to have_been_requested

      end
    end
  end
end