# frozen_string_literal: true

ShopifyBilling::Engine.routes.draw do
  root to: 'billings#index'
  post 'billing/charge', to: 'billings#create_charge'
  get 'billing/plans', to: 'billings#show'
  post 'billing/check_coupon', to: 'billings#check_coupon'
  get 'handle_charge', to: 'billing_callbacks#handle_charge'
end
