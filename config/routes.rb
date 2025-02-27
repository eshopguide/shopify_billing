ShopifyBilling::Engine.routes.draw do
  post 'billing/charge', to: 'billings#create_charge'
  get 'billing/plans', to: 'billings#show'
  get 'handle_charge', to: 'billing_callbacks#handle_charge'
end

