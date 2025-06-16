# frozen_string_literal: true

module ShopifyBilling
  class ResetBillingPlanJob < ApplicationJob
    queue_as :default

    def perform(shop_id)
      shop = Shop.find_by(id: shop_id)
      return unless shop.present? && shop.plan_mismatch_since.present?

      ResetBillingPlanService.call(shop:)
    end
  end
end
