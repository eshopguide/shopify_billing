# frozen_string_literal: true

FactoryBot.define do
  factory :coupon_code, class: 'ShopifyBilling::CouponCode' do
    sequence(:coupon_code) { |n| "CODE#{n}" }
    redeem_counter { 1 }
    validity { 1.month.from_now.to_date }
    free_days { 30 }
    redeemed { false }

    factory :one_time_coupon_code, class: 'ShopifyBilling::OneTimeCouponCode' do
      # Add any specific attributes for one-time coupon codes
    end

    factory :campaign_coupon_code, class: 'ShopifyBilling::CampaignCouponCode' do
      # Add any specific attributes for campaign coupon codes
    end
  end
end