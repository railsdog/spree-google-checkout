Spree::Core::Engine.routes.prepend do
  resources :google_checkout_notification
  namespace :admin do
    resources :orders do 
      member do
        get :charge_google_order
        get :cancel_google_checkout_order
      end
    end
  end
end
