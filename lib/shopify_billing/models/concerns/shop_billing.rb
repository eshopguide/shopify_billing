module ShopifyBilling
  module ShopBilling
    extend ActiveSupport::Concern

    included do
      # You can add any class-level configurations here
      # For example: has_many :invoices
    end

    def feature_enabled?(key)
      billing_plan.features.include?(key)
    end

    def billing_plan
      ShopifyBilling::Charge.find_by(shopify_id: app_subscription&.id)&.billing_plan
    end

    def import_unlocked?
      import_manually_unlocked_at.present? || import_unlocked_at.present?
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

    def after_activate_one_time_purchase(_charge)
      update!(import_unlocked_at: Time.zone.now)

      NotificationsJob.perform_async(@shop.to_json, 'import', 'notification') if Rails.env.production?
    end

    def send_install_notifications
      return unless Rails.env.production?

      # send welcome email to shop owner
      NotificationsJob.perform_async(to_json, 'new_install', 'email')
      # notify slack channel
      NotificationsJob.perform_async(to_json, 'install', 'notification')
    end

    private

    def app_installation_cache_key
      "app_installation_#{shopify_domain}"
    end
  end
end
