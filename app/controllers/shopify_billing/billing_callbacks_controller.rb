# frozen_string_literal: true

module ShopifyBilling
  class BillingCallbacksController < ShopifyBilling::AuthenticatedController

    def handle_charge
      result = ShopifyBilling::HandleChargeService.call(
        shop_id: params.require(:shop_id),
        charge_id: params.require(:charge_id),
        billing_plan_id: params.require(:billing_plan_id),
        coupon_code: params[:coupon_code],
        token: params.require(:token)
      )

      redirect_to_admin(nil, result)
    end
  end
end
