Rails.application.routes.draw do


  resources :orders do
    mount ShiftCommerce::UiPaymentGateway::Engine => "/transactions"
  end
end
