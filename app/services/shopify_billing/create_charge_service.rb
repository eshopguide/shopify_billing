# frozen_string_literal: true

module ShopifyBilling
  class CreateChargeService < ShopifyBilling::BaseReportingService
    def initialize(shop:, billing_plan_id:, host:, coupon_code: nil)
      @shop = shop
      @billing_plan = ShopifyBilling::BillingPlan.find(billing_plan_id)
      @coupon_code = coupon_code
      @host = host
    end

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity
    def call
      return if @shop.nil? || @billing_plan.nil? || @host.nil?

      if @billing_plan.recurring?
        if @coupon_code.present?
          coupon = ShopifyBilling::CouponCode.find_by(coupon_code: @coupon_code)
          coupon.assign_to_shop(@shop)
          @billing_plan.apply_coupon(coupon)
        end

        subscription = CreateAppSubscription.call(variables: recurring_charge_attributes)
        charge = subscription.data
      else
        one_time_charge = AppPurchaseOneTimeCreate.call(variables: charge_attributes)
        charge = one_time_charge.data
      end

      # Log the plan click before creating the charge
      log_plan_click

      # Create charge in our database
      shopify_charge_id = if @billing_plan.recurring?
                            charge.appSubscription.id
                          else
                            charge.appPurchaseOneTime.id
                          end

      ShopifyBilling::Charge.create!(
        shopify_id: shopify_charge_id,
        billing_plan: @billing_plan
      )

      charge
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity

    private

    def log_plan_click
      report_event(
        event_name: 'plan_click',
        event_type: 'engagement',
        customer_myshopify_domain: @shop.shopify_domain,
        event_value: @billing_plan.name,
        payload: {
          plan_price: @billing_plan.price_for_shop(@shop)
        },
        timestamp: Time.current
      )
    end

    def charge_attributes
      {
        name: @billing_plan.name,
        price: {
          amount: @billing_plan.price_for_shop(@shop),
          currencyCode: @billing_plan.currency
        },
        returnUrl: return_url,
        test:
      }
    end

    def recurring_charge_attributes
      {
        name: @billing_plan.name,
        trialDays: @billing_plan.trial_days_for_shop(@shop),
        returnUrl: return_url,
        test:,
        lineItems: [
          plan: {
            appRecurringPricingDetails: {
              interval: @billing_plan.interval,
              price: {
                amount: @billing_plan.price_for_shop(@shop),
                currencyCode: @billing_plan.currency
              }
            }
          }
        ]
      }
    end

    def test
      ENV.fetch('TEST_CHARGE').to_s.casecmp('true').zero? ||
        @billing_plan.development_plan? ||
        @shop.internal_test_shop?
    end

    def return_url
      params = {
        shop_id: @shop.id,
        host: @host,
        billing_plan_id: @billing_plan.id,
        token: verification_token
      }
      params[:coupon_code] = @coupon_code if @coupon_code.present? && @billing_plan.recurring?

      URI::HTTPS.build(
        host: ENV.fetch('HOST_NAME'),
        path: '/shopify_billing/handle_charge',
        query: params.to_query
      ).to_s
    end

    def verification_token
      Digest::SHA1.hexdigest([@shop.id, @billing_plan.id].join('|'))
    end
  end
end
