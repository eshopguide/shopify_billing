# frozen_string_literal: true

FactoryBot.define do
  factory :shop do
    sequence(:shopify_domain) { |n| "shop#{n}.myshopify.com" }
    shopify_token { "token123" }
    development_shop { false }
    discount_percent { 0 }
    import_discount_percent { 0 }
    import_unlocked { false }
    tmp_has_missing_recurring_charge { false }
    
    trait :development do
      development_shop { true }
    end
  end
end 