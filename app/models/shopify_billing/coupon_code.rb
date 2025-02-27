# frozen_string_literal: true

module ShopifyBilling
  class InvalidCouponError < StandardError; end

  # base class for Coupons
  class CouponCode < ApplicationRecord
    self.table_name = 'coupon_codes'

    def assign_to_shop(shop)
      shop.update!(redeemed_coupon_id: id)
    end

    def redeem(shop)
      raise InvalidCouponError unless coupon_valid?(shop)

      update!(redeem_counter: redeem_counter - 1)
      shop.update!(redeemed_coupon_id: id)
    end

    def coupon_valid?(shop)
      validity >= Time.zone.today && redeem_counter.positive?
    end
  end
end
