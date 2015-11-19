module ShiftCommerce
  module UiPaymentGateway
    class Engine < ::Rails::Engine
      isolate_namespace UiPaymentGateway
      initializer "Setup active merchant" do
        ActiveMerchant::Billing::Base.mode = :test if ::ShiftCommerce::UiPaymentGateway::Config.instance.test_mode
      end
    end
  end
end
