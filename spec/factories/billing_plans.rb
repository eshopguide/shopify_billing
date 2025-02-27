# frozen_string_literal: true

FactoryBot.define do
  factory :billing_plan, class: 'ShopifyBilling::BillingPlan' do
    sequence(:name) { |n| "Plan #{n}" }
    sequence(:short_name) { |n| "plan_#{n}" }
    price { 19.99 }
    plan_type { "recurring" }
    available_for_development_shop { true }
    available_for_production_shop { true }
    
    trait :one_time do
      plan_type { "one_time" }
    end
  end
end 