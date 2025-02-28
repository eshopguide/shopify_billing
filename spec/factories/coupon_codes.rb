# frozen_string_literal: true

FactoryBot.define do
  factory :coupon_code, class: 'ShopifyBilling::CouponCode' do
    coupon_code { SecureRandom.uuid.delete('-').upcase.slice(0, 6) }
    redeemed { false }
    shop_id { nil }
    free_days { [1..60].sample }
    validity { Date.today + rand(1..60).days }
    type { 'ShopifyBilling::CouponCode' }
    redeem_counter { rand(1..10) }
    trait :redeemed do
      redeemed { true }
    end

    factory :one_time_coupon_code, class: 'ShopifyBilling::OneTimeCouponCode' do
      type { 'ShopifyBilling::OneTimeCouponCode' }
    end

    factory :campaign_coupon_code, class: 'ShopifyBilling::CampaignCouponCode' do
      type { 'ShopifyBilling::CampaignCouponCode' }
    end
  end
end