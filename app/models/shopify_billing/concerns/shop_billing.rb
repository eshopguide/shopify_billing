# frozen_string_literal: true

module ShopifyBilling
  module Concerns
    module ShopBilling
      extend ActiveSupport::Concern

      def feature_enabled?(key)
        billing_plan&.features&.include?(key) || false
      end

      def billing_plan
        ShopifyBilling::Charge.find_by(shopify_id: app_subscription&.id)&.billing_plan
      end

      def plan_active?
        billing_plan.present?
      end

      def remaining_trial_days
        ((trial_ends_on || Time.zone.today) - Time.zone.today).to_i
      end

      def development_shop?
        shopify_plan.partnerDevelopment
      end

      def app_subscription
        app_installation.activeSubscriptions.first
      end

      def app_installation
        @app_installation ||= Rails.cache.fetch(app_installation_cache_key, expires_in: 1.hour) do
          with_shopify_session do
            GetAppInstallation.call
          end
        end
      end

      def install_date
        created_at.strftime('%Y-%m-%d')
      end

      def reset_app_installation_cache
        Rails.cache.delete(app_installation_cache_key)
      end

      def shopify_plan
        @shopify_plan ||= with_shopify_session do
          GetShopifyPlan.call
        end
      end

      def after_activate_one_time_purchase
        raise NotImplementedError, 'after_activate_one_time_purchase must be implemented by the host application'
      end

      def send_plan_mismatch_notification
        raise NotImplementedError, 'send_plan_mismatch_notification must be implemented by the host application'
      end

      private

      def app_installation_cache_key
        "app_installation_#{shopify_domain}"
      end
    end
  end
end
