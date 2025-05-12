# frozen_string_literal: true

FactoryBot.define do
  factory :billing_plan, class: 'ShopifyBilling::BillingPlan' do
    name { 'Import' }
    short_name { 'Import' }
    price { rand(0.0...100.0).round(2) }
    warning { nil }
    threshold { nil }
    default { nil }
    plan_type { 'recurring' }
    matches_shopify_plan { nil }
    recommended { false }
    development_plan { false }
    available_for_development_shop { false }
    available_for_production_shop { true }
    interval { ['EVERY_30_DAYS', 'ANNUAL'].sample }
    is_legacy { false }

    trait :with_default_id do
      id { 1 }
    end
  end

  trait :import_plan do
    name { 'Import' }
    short_name { 'Import' }
    price { 99.00 }
    plan_type { 'one_time' }
    matches_shopify_plan { nil }
  end

  trait :auto_sync do
    name { 'lexoffice Autosync' }
    short_name { 'basic' }
    price { 10.00 }
    warning { nil }
    threshold { nil }
    default { nil }
    plan_type { 'recurring' }
    matches_shopify_plan { nil }
  end
end
