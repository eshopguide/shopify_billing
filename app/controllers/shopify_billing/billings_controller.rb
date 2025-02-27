# frozen_string_literal: true

module ShopifyBilling
  class BillingsController < ShopifyBilling::AuthenticatedController
    before_action :set_current_shop
    def show
      plans = ShopifyBilling::SelectAvailableBillingPlansService.call(
        shop: @current_shop,
        coupon_code: params[:coupon_code]
      )

      render json: plans
    end

    def create_charge
      charge = ShopifyBilling::CreateChargeService.call(
        shop: @current_shop,
        billing_plan_id: params.require(:plan_id),
        coupon_code: params[:coupon_code],
        host: shopify_host
      )

      if charge&.confirmation_url
        render json: { success: true, confirmation_url: charge.confirmation_url }
      else
        render json: { success: false }
      end
    end
  end
end