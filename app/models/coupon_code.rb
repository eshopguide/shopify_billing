# frozen_string_literal: true

module ShopifyBilling
  class InvalidCouponError < StandardError; end

  # base class for Coupons
  class CouponCode < ApplicationRecord
  end
end
