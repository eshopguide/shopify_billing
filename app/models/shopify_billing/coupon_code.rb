# frozen_string_literal: true

module ShopifyBilling
  class InvalidCouponError < StandardError; end

  # base class for Coupons
  class CouponCode < ApplicationRecord
    self.table_name = 'coupon_codes'

    def self.find_sti_class(type_name)
      if type_name.include?('::')
        type_name.constantize
      else
        "ShopifyBilling::#{type_name}".constantize
      end
    rescue NameError
      super
    end

    def self.sti_name
      name.demodulize
    end
  end
end
