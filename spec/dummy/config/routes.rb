Rails.application.routes.draw do

  mount ShiftCommerce::UiPaymentGateway::Engine => "/ui_payment_gateway"
  resources :carts do
    resources :transactions do
      collection do
        get :new_with_token
      end
    end
  end
end
