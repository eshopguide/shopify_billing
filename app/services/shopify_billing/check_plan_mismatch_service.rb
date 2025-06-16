# frozen_string_literal: true

module ShopifyBilling
  class CheckPlanMismatchService < ApplicationService
    def initialize(shop:)
      @shop = shop
    end

    def call
      return if @shop.nil? || @shop.plan_mismatch_since? || @shop.billing_plan.nil?
      return unless !@shop.development_shop? && @shop.billing_plan.development_plan?

      Shop.transaction do
        @shop.update!(plan_mismatch_since: DateTime.now)

        # Send plan update mail now
        SendPlanMismatchNotificationJob.perform_later(@shop.id)

        # Send reminder in 13 days
        SendPlanMismatchNotificationJob.set(wait: 13.days).perform_later(@shop.id)

        # Reset billing plan in 14 days
        ResetBillingPlanJob.set(wait: 14.days).perform_later(@shop.id)
      end
    end
  end
end
