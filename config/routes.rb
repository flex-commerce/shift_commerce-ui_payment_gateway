ShiftCommerce::UiPaymentGateway::Engine.routes.draw do
  resources :transactions, path: "/", only: [:new, :create] do
    collection do
      get "/new/:gateway", action: "new_with_gateway", as: :new_with_gateway
      get :new_with_token
    end
  end

end
