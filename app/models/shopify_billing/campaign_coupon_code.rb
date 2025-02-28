# frozen_string_literal: true

module ShopifyBilling
  class CampaignCouponCode < ShopifyBilling::CouponCode
    has_many :shops
    validates :coupon_code, presence: true, format: { with: /\A[0-9a-zA-Z'-]*\z/ }, uniqueness: true

    def assign_to_shop(shop)
      # Campaign Codes don't need to be assigned – do nothing
    end

    def redeem(shop)
      raise InvalidCouponError unless coupon_valid?(shop)

      ActiveRecord::Base.transaction do
        update!(redeem_counter: redeem_counter - 1)
        shop.update!(redeemed_coupon_id: id)
      end
    end

    def coupon_valid?(_shop)
      validity >= Time.zone.today && redeem_counter.positive?
    end
  end
end