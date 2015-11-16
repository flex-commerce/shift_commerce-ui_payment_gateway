Rails.application.routes.draw do
  mount ShiftCommerce::UiPaymentGateway::Engine => "/payment_gateway"
  resource :cart do

  end
  resources :orders do
    resources :transactions, only: [:new, :create] do
      collection do
        get "/new/:gateway", action: "new_with_gateway", as: :new_with_gateway
        get "/new_with_token/:gateway", action: :new_with_token, as: :new_with_gateway_and_token
      end
    end
  end
end
