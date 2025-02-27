# frozen_string_literal: true

# a One time coupon code that is bound to a particular shop

module ShopifyBilling
  class OneTimeCouponCode < ShopifyBilling::CouponCode
    belongs_to :shop, optional: true
    validates :coupon_code, presence: true, format: { with: /\A[0-9A-Z'-]*\z/ }, length: { is: 6 }, uniqueness: true

    def assign_to_shop(shop)
      raise InvalidCouponError unless valid? && coupon_valid?(shop)

      update!(shop_id: shop.id)
    end

    def redeem(shop)
      raise InvalidCouponError unless valid? && coupon_valid?(shop)

      update!(redeemed: true, redeem_counter: redeem_counter - 1)
    end

    def coupon_valid?(shop)
      (!shop_id || shop_id == shop.id) && redeem_counter.positive? && !redeemed?
    end
  end
end