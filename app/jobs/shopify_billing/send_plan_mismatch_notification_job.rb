# frozen_string_literal: true

module ShopifyBilling
  class SendPlanMismatchNotificationJob < ApplicationJob
    queue_as :default

    def perform(shop_id)
      shop = Shop.find_by(id: shop_id)
      return unless shop.present? && shop.plan_mismatch_since.present?

      shop.send_plan_mismatch_notification
    end
  end
end
