# frozen_string_literal: true

module ShopifyBilling
  class InvalidCouponError < StandardError; end

  # base class for Coupons
  class CouponCode < ApplicationRecord
    self.table_name = 'coupon_codes'
  end
end
