# frozen_string_literal: true

FactoryBot.define do
  factory :coupon_code, class: 'ShopifyBilling::OneTimeCouponCode' do
    coupon_code { SecureRandom.uuid.delete('-').upcase.slice(0, 6) }
    redeemed { false }
    shop_id { nil }
    free_days { rand(1..60) }
    validity { Date.today + rand(1..60).days }
    redeem_counter { rand(1..10) }

    trait :redeemed do
      redeemed { true }
    end
  end

  factory :campaign_coupon_code, class: 'ShopifyBilling::CampaignCouponCode' do
    coupon_code { SecureRandom.uuid.delete('-').upcase.slice(0, 6) }
    redeemed { false }
    free_days { rand(1..60) }
    validity { Date.today + rand(1..60).days }
    redeem_counter { rand(1..10) }
  end
end
