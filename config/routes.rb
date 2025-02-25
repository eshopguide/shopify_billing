ShopifyBilling::Engine.routes.draw do
  post 'billing/charge', to: 'billings#create_charge'
end

