# frozen_string_literal: true

module ShopifyBilling
  class BillingsController < ::AuthenticatedController

    def show
      plans = ShopifyBilling::SelectAvailableBillingPlansService.call(
        shop: @current_shop,
        coupon_code: params[:coupon_code]
      )

      render json: plans
    end
    def create_charge
      charge = ShopifyBilling::CreateChargeService.call(
        shop: params[:shop],
        billing_plan_id: params[:billing_plan_id],
        host: params[:host],
        coupon_code: params[:coupon_code]
      )

      if charge
        render json: { charge_url: charge.confirmation_url }
      else
        render json: { error: 'Failed to create charge' }, status: :unprocessable_entity
      end
    end
  end
end