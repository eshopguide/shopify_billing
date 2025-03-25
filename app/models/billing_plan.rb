# frozen_string_literal: true

# The BillingPlan class stores the billing plan information. Every Shop gets assigned a BillingPlan.
module BillingPlanExtensions
  def current_for_shop?(shop)
    (recurring? && shop.billing_plan&.id == id) || (one_time? && shop.import_unlocked?)
  end
end

ShopifyBilling::BillingPlan.prepend(BillingPlanExtensions) 