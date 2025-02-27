# frozen_string_literal: true

module ShopifyBilling
  class BillingPlan < ApplicationRecord
    self.table_name = 'billing_plans'
    has_many :charges

    scope :free, -> { find_by(short_name: 'FreePlan') }

    def recurring?
      plan_type == 'recurring'
    end

    def one_time?
      plan_type == 'one_time'
    end

    def apply_coupon(coupon)
      @coupon = coupon
    end

    def trial_days_for_shop(shop)
      return 0 unless base_trial_days.positive?
      return @coupon.free_days if @coupon && @coupon.free_days.to_i.positive?

      if shop.trial_ends_on.present?
        [0, shop.remaining_trial_days.to_i].max
      else
        base_trial_days
      end
    end

    def base_trial_days
      return 0 if plan_type == 'one_time' || development_plan?

      ENV.fetch('TRIAL_DAYS').to_i
    end

    def current_for_shop?(shop)
      (recurring? && shop.billing_plan&.id == id) || (one_time? && shop.import_unlocked)
    end

    def discount_for_shop(shop)
      recurring? ? shop.discount_percent : shop.import_discount_percent
    end

    def price_for_shop(shop)
      discount = discount_for_shop(shop)
      discounted_price = (price * ((100 - discount) / 100.0))
      [discounted_price, 1].max
    end
  end
end
