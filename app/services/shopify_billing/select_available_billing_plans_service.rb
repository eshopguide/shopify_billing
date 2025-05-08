# frozen_string_literal: true

module ShopifyBilling
  class SelectAvailableBillingPlansService < ShopifyBilling::ApplicationService
    def initialize(shop:, coupon_code:)
      @shop = shop
      @coupon_code = coupon_code
    end

    def call
      billing_plans = fetch_base_billing_plans
      billing_plans = apply_coupon_if_present(billing_plans)
      billing_plans = filter_by_shop_type(billing_plans)

      transform_billing_plans(billing_plans)
    end

    private

    def fetch_base_billing_plans
      ShopifyBilling::BillingPlan.non_legacy.where('id > 0').order('price')
    end

    def apply_coupon_if_present(billing_plans)
      return billing_plans if @coupon_code.blank?

      coupon = find_and_validate_coupon
      apply_coupon_to_plans(billing_plans, coupon)
    end

    def find_and_validate_coupon
      coupon = ShopifyBilling::CouponCode.find_by!(coupon_code: @coupon_code)
      raise InvalidCouponError unless coupon.coupon_valid?(@shop)

      coupon
    end

    def apply_coupon_to_plans(billing_plans, coupon)
      billing_plans.map do |billing_plan|
        billing_plan.apply_coupon(coupon) if billing_plan.recurring?
        billing_plan
      end
    end

    def filter_by_shop_type(billing_plans)
      billing_plans.filter do |plan|
        @shop.development_shop? ? plan.available_for_development_shop? : plan.available_for_production_shop?
      end
    end

    def transform_billing_plans(billing_plans)
      billing_plans.group_by(&:plan_type).transform_values do |plans|
        plans.map { |plan| build_plan_hash(plan) }
      end
    end

    def build_plan_hash(billing_plan)
      {
        id: billing_plan.id,
        name: billing_plan.name,
        short_name: billing_plan.short_name,
        recommended: billing_plan.recommended?,
        is_current_plan: plan_is_current?(billing_plan),
        price: billing_plan.price_for_shop(@shop),
        discount: billing_plan.discount_for_shop(@shop),
        trial_days: billing_plan.trial_days_for_shop(@shop),
        base_trial_days: billing_plan.base_trial_days,
        plan_type: billing_plan.plan_type,
        development_plan: billing_plan.development_plan?,
        available: billing_plan.plan_available?(@shop),
        interval: billing_plan.interval
      }
    end

    def plan_is_current?(billing_plan)
      !@shop.tmp_has_missing_recurring_charge && billing_plan.current_for_shop?(@shop)
    end
  end
end
