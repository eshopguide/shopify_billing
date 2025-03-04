# frozen_string_literal: true

FactoryBot.define do
  factory :charge, class: 'ShopifyBilling::Charge' do
    shopify_id { "gid://shopify/AppSubscription/#{Faker::Number.number(digits: 10)}" }
    billing_plan { create(:billing_plan, plan_type: 'recurring') }

    trait :one_time do
      shopify_id { "gid://shopify/AppPurchaseOneTime/#{Faker::Number.number(digits: 10)}" }
      billing_plan { create(:billing_plan, plan_type: 'one_time') }
    end
  end
end
