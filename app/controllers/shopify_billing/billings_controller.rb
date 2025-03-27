# frozen_string_literal: true

module ShopifyBilling
  class BillingsController < Object.const_get(ShopifyBilling.authenticated_controller)
    before_action :init_shop_settings

    def show
      plans = ShopifyBilling::SelectAvailableBillingPlansService.call(
        shop: @current_shop,
        coupon_code: params[:coupon_code]
      )

      render json: plans
    end

    def check_coupon
      coupon_code = params.require(:coupon_code)
      coupon = ShopifyBilling::CouponCode.find_by!(coupon_code:)

      # Temporary coupon that is only valid for new customers
      if coupon_code == 'EshopGuide60'
        current_charge = @current_shop.with_shopify_session do
          ShopifyAPI::RecurringApplicationCharge.current
        end

        return head :not_found if current_charge.present?
      end

      return head :not_found unless coupon.coupon_valid?(@current_shop)

      render json: { valid: true }
    end

    # rubocop:disable Metrics/MethodLength
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
    # rubocop:enable Metrics/MethodLength
  end
end
