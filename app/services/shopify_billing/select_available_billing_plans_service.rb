
module ShopifyBilling
  class SelectAvailableBillingPlansService < ShopifyBilling::ApplicationService
    def initialize(shop:, coupon_code:)
      @shop = shop
      @coupon_code = coupon_code
    end

    def call
      billing_plans = BillingPlan.where('id > 0').order('price')

      if @coupon_code.present?
        coupon = CouponCode.find_by!(coupon_code: @coupon_code)

        raise InvalidCouponError unless coupon.coupon_valid?(@shop)

        billing_plans = billing_plans.map do |billing_plan|
          billing_plan.apply_coupon(coupon) if billing_plan.recurring?
          billing_plan
        end
      end

      billing_plans = billing_plans.filter do |plan|
        @shop.development_shop? ? plan.available_for_development_shop? : plan.available_for_production_shop?
      end

      transform_billing_plans(billing_plans)
    end

    private

    def transform_billing_plans(billing_plans)
      billing_plans.group_by(&:plan_type).transform_values do |plans|
        plans.map do |billing_plan|
          {
            id: billing_plan.id,
            name: billing_plan.name,
            short_name: billing_plan.short_name,
            recommended: billing_plan.recommended?,
            is_current_plan: !@shop.tmp_has_missing_recurring_charge && billing_plan.current_for_shop?(@shop),
            price: billing_plan.price_for_shop(@shop),
            discount: billing_plan.discount_for_shop(@shop),
            trial_days: billing_plan.trial_days_for_shop(@shop),
            base_trial_days: billing_plan.base_trial_days,
            plan_type: billing_plan.plan_type,
            development_plan: billing_plan.development_plan?
          }
        end
      end
    end
  end
end