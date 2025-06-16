# frozen_string_literal: true

module ShopifyBilling
  class ResetBillingPlanService < ApplicationService
    def initialize(shop:)
      @shop = shop
    end

    def call
      return if @shop.nil?

      Shop.transaction do
        @shop.update!(plan_mismatch_since: nil)

        # Cancel Shopify recurring charge
        @shop.with_shopify_session do
          current_charge = ShopifyAPI::RecurringApplicationCharge.current

          ShopifyAPI::RecurringApplicationCharge.delete(id: current_charge.id) unless current_charge.nil?
        end

        # Reset app installation cache
        @shop.reset_app_installation_cache
      end
    end
  end
end
