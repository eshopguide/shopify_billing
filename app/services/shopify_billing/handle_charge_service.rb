# frozen_string_literal: true

module ShopifyBilling
  class HandleChargeService < ShopifyBilling::BaseReportingService
    def initialize(shop_id:, charge_id:, billing_plan_id:, coupon_code:, token:)
      @shop = Shop.find(shop_id)
      @charge_id = charge_id
      @billing_plan = ShopifyBilling::BillingPlan.find(billing_plan_id)
      @coupon_code = coupon_code
      @token = token
    end

    def call
      return if @shop.nil? || @charge_id.nil? || @billing_plan.nil?
      raise 'Verification failed' if @token != verification_token

      charge = find_charge
      process_charge(charge)
    end

    def find_charge
      @shop.with_shopify_session do
        if @billing_plan.recurring?
          ShopifyAPI::RecurringApplicationCharge.find(id: @charge_id)
        else
          ShopifyAPI::ApplicationCharge.find(id: @charge_id)
        end
      end
    end

    private

    def process_charge(charge)
      result = process_charge_transaction(charge)
      log_purchase_event(charge) if %w[plan_activated import_plan_activated].include?(result)
      result
    end

    def process_charge_transaction(charge)
      return 'declined' unless charge.status == 'active'

      ActiveRecord::Base.transaction do
        process_coupon
        @shop.reset_app_installation_cache
        process_billing_plan(charge)
      end
    end

    def process_coupon
      return unless @coupon_code

      coupon = ShopifyBilling::CouponCode.find_by(coupon_code: @coupon_code)
      coupon.redeem(@shop)
    end

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def process_billing_plan(charge)
      if @billing_plan.recurring?
        @previous_plan_id = @shop.billing_plan&.id

        if charge.trial_ends_on.respond_to?(:to_date) && charge.trial_ends_on.to_date > Time.zone.today
          @shop.trial_ends_on = charge.trial_ends_on
        end
        @shop.plan_mismatch_since = nil
        @shop.tmp_has_missing_recurring_charge = false
        @shop.save!

        'plan_activated'
      elsif @billing_plan.one_time?
        @shop.after_activate_one_time_purchase(charge) if @shop.respond_to?(:after_activate_one_time_purchase)
        'import_plan_activated'
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    def verification_token
      Digest::SHA1.hexdigest([@shop.id, @billing_plan.id].join('|'))
    end

    # rubocop:disable Metrics/MethodLength
    def log_purchase_event(charge)
      event_name = @billing_plan.recurring? ? 'plan_activation' : 'one_time_purchase'
      external_id = if @billing_plan.recurring?
                      "gid://shopify/AppSubscription/#{charge.id}"
                    else
                      "gid://shopify/AppPurchaseOneTime/#{charge.id}"
                    end

      report_event(
        event_name:,
        event_type: 'conversion',
        customer_myshopify_domain: @shop.shopify_domain,
        customer_info: {
          name: @shop.name,
          owner: @shop.shop_owner,
          email: @shop.email
        },
        event_value: @billing_plan.name,
        payload: {
          change_type: determine_change_type(@previous_plan_id),
          price_at_activation: charge.price
        },
        timestamp: Time.current,
        external_id:
      )
    end
    # rubocop:enable Metrics/MethodLength

    def determine_change_type(previous_plan_id)
      return 'new' if previous_plan_id.nil? || previous_plan_id.zero?

      previous_plan = ShopifyBilling::BillingPlan.find_by(id: previous_plan_id)
      return 'new' if previous_plan.nil?

      @billing_plan.price > previous_plan.price ? 'upgrade' : 'downgrade'
    end
  end
end
