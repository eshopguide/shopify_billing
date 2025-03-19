# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShopifyBilling::ShopBilling do
  let(:shop) { create(:shop) }
  let(:billing_plan) { create(:billing_plan) }

  before do
    allow(shop).to receive(:app_installation).and_return(nil)
  end

  describe '#feature_enabled?' do
    before do
      allow(shop).to receive(:billing_plan).and_return(nil)
    end

    it 'returns false when no billing plan is attached' do
      expect(shop.feature_enabled?('some_feature')).to be false
    end

    it 'returns true when the feature is included in the plan features' do
      plan = create(:billing_plan, features: ['some_feature'])
      allow(shop).to receive(:billing_plan).and_return(plan)

      expect(shop.feature_enabled?('some_feature')).to be true
    end
  end

  describe '#billing_plan' do
    let(:charge) { create(:charge) }

    context 'when a charge exists with matching app subscription id' do
      before do
        allow(shop).to receive(:app_subscription).and_return(double('AppSubscription', id: charge.shopify_id))
      end

      it 'returns the billing plan associated with the charge' do
        expect(shop.billing_plan).to eq(charge.billing_plan)
      end
    end

    context 'when no charge exists with matching app subscription id' do
      before do
        allow(shop).to receive(:app_subscription).and_return(double('AppSubscription', id: 'non_existent_id'))
      end

      it 'returns nil' do
        expect(shop.billing_plan).to be_nil
      end
    end

    context 'when app_subscription is nil' do
      before do
        allow(shop).to receive(:app_subscription).and_return(nil)
      end

      it 'returns nil' do
        expect(shop.billing_plan).to be_nil
      end
    end
  end

  describe '#import_unlocked?' do
    context 'when import_manually_unlocked_at is present' do
      it 'returns true' do
        shop.update(import_manually_unlocked_at: Time.zone.now)
        expect(shop.import_unlocked?).to be true
      end
    end

    context 'when import_unlocked_at is present' do
      it 'returns true' do
        shop.update(import_unlocked_at: Time.zone.now)
        expect(shop.import_unlocked?).to be true
      end
    end

    context 'when both import_manually_unlocked_at and import_unlocked_at are nil' do
      it 'returns false' do
        shop.update(import_manually_unlocked_at: nil, import_unlocked_at: nil)
        expect(shop.import_unlocked?).to be false
      end
    end
  end

  describe '#plan_active?' do
    context 'when billing_plan is present' do
      before do
        allow(shop).to receive(:billing_plan).and_return(billing_plan)
      end

      it 'returns true' do
        expect(shop.plan_active?).to be true
      end
    end

    context 'when billing_plan is not present' do
      before do
        allow(shop).to receive(:billing_plan).and_return(nil)
      end

      it 'returns false' do
        expect(shop.plan_active?).to be false
      end
    end
  end

  describe '#remaining_trial_days' do
    context 'when trial_ends_on is in the future' do
      it 'returns the correct number of days' do
        future_date = Time.zone.today + 5.days
        shop.update(trial_ends_on: future_date)

        expect(shop.remaining_trial_days).to eq(5)
      end
    end

    context 'when trial_ends_on is today' do
      it 'returns 0' do
        shop.update(trial_ends_on: Time.zone.today)

        expect(shop.remaining_trial_days).to eq(0)
      end
    end

    context 'when trial_ends_on is in the past' do
      it 'returns a negative number' do
        past_date = Time.zone.today - 3.days
        shop.update(trial_ends_on: past_date)

        expect(shop.remaining_trial_days).to eq(-3)
      end
    end

    context 'when trial_ends_on is nil' do
      it 'uses today as the default value' do
        shop.update(trial_ends_on: nil)

        expect(shop.remaining_trial_days).to eq(0)
      end
    end
  end

  describe '#app_subscription' do
    let(:app_subscription) { double('AppSubscription') }
    let(:app_installation) { double('AppInstallation', activeSubscriptions: [app_subscription]) }

    before do
      allow(shop).to receive(:app_installation).and_return(app_installation)
    end

    it 'returns the first active subscription from app_installation' do
      expect(shop.app_subscription).to eq(app_subscription)
    end

    context 'when app_installation has no active subscriptions' do
      before do
        allow(app_installation).to receive(:activeSubscriptions).and_return([])
      end

      it 'returns nil' do
        expect(shop.app_subscription).to be_nil
      end
    end
  end

  describe '#app_installation' do
    let(:app_installation) { double('AppInstallation') }

    before do
      allow(shop).to receive(:app_installation).and_call_original
      allow(Rails.cache).to receive(:fetch).and_yield
      allow(shop).to receive(:with_shopify_session).and_yield
      allow(GetAppInstallation).to receive(:call).and_return(app_installation)
    end

    it 'fetches app installation from cache' do
      expect(Rails.cache).to receive(:fetch).with(
        "app_installation_#{shop.shopify_domain}", 
        expires_in: 1.hour
      )

      shop.app_installation
    end

    it 'calls GetAppInstallation within a Shopify session' do
      expect(shop).to receive(:with_shopify_session)
      expect(GetAppInstallation).to receive(:call)

      shop.app_installation
    end

    it 'returns the app installation' do
      expect(shop.app_installation).to eq(app_installation)
    end
  end

  describe '#install_date' do
    let(:created_at) { Time.zone.parse('2023-05-15 12:34:56') }

    before do
      shop.created_at = created_at
    end

    it 'returns the shop creation date formatted as YYYY-MM-DD' do
      expect(shop.install_date).to eq('2023-05-15')
    end
  end

  describe '#reset_app_installation_cache' do
    it 'deletes the app installation cache key' do
      cache_key = "app_installation_#{shop.shopify_domain}"
      expect(Rails.cache).to receive(:delete).with(cache_key)

      shop.reset_app_installation_cache
    end
  end

  describe '#shopify_plan' do
    let(:shopify_plan) { double('ShopifyPlan') }

    before do
      allow(shop).to receive(:with_shopify_session).and_yield
      allow(GetShopifyPlan).to receive(:call).and_return(shopify_plan)
    end

    it 'caches the result' do
      expect(GetShopifyPlan).to receive(:call).once
      first_result = shop.shopify_plan

      # Second call should use the cached value
      second_result = shop.shopify_plan

      expect(first_result).to eq(second_result)
    end

    it 'calls GetShopifyPlan within a Shopify session' do
      expect(shop).to receive(:with_shopify_session)
      expect(GetShopifyPlan).to receive(:call)

      shop.shopify_plan
    end

    it 'returns the shopify plan' do
      expect(shop.shopify_plan).to eq(shopify_plan)
    end
  end

  describe '#after_activate_one_time_purchase' do
    let(:charge) { double('Charge') }

    it 'updates import_unlocked_at to current time' do
      current_time = Time.zone.now
      allow(Time.zone).to receive(:now).and_return(current_time)

      expect(shop).to receive(:update!).with(import_unlocked_at: current_time)

      shop.after_activate_one_time_purchase(charge)
    end

    context 'when in production environment' do
      before do
        allow(Rails.env).to receive(:production?).and_return(true)
      end

      it 'schedules a notifications job' do
        expect(NotificationsJob).to receive(:perform_async).with(anything(), 'import', 'notification')

        shop.after_activate_one_time_purchase(charge)
      end
    end

    context 'when not in production environment' do
      before do
        allow(Rails.env).to receive(:production?).and_return(false)
      end

      it 'does not schedule a notifications job' do
        expect(NotificationsJob).not_to receive(:perform_async)

        shop.after_activate_one_time_purchase(charge)
      end
    end
  end

  describe '#send_install_notifications' do
    context 'when in production environment' do
      before do
        allow(Rails.env).to receive(:production?).and_return(true)
      end

      it 'sends welcome email notification' do
        allow(NotificationsJob).to receive(:perform_async)
        expect(NotificationsJob).to receive(:perform_async).with(shop.to_json, 'new_install', 'email')

        shop.send_install_notifications
      end

      it 'sends installation notification to slack' do
        allow(NotificationsJob).to receive(:perform_async)

        expect(NotificationsJob).to receive(:perform_async).with(shop.to_json, 'install', 'notification')

        shop.send_install_notifications
      end
    end

    context 'when not in production environment' do
      before do
        allow(Rails.env).to receive(:production?).and_return(false)
      end

      it 'does not send any notifications' do
        expect(NotificationsJob).not_to receive(:perform_async)

        shop.send_install_notifications
      end
    end
  end

  describe '#app_installation_cache_key' do
    it 'returns the correct cache key format' do
      expected_key = "app_installation_#{shop.shopify_domain}"

      # Use send to call private method
      actual_key = shop.send(:app_installation_cache_key)

      expect(actual_key).to eq(expected_key)
    end
  end

  describe '#development_shop?' do
    let(:shop) { create(:shop) }

    context 'when it is a development shop' do
      before do
        allow(shop).to receive(:app_installation).and_return(nil)
      end

      it 'returns true' do
        allow(shop).to receive(:shopify_plan).and_return(
          double('Plan', displayName: 'Shopify Plus Partner Sandbox', partnerDevelopment: true, shopifyPlus: true)
        )

        expect(shop).to be_development_shop
      end
    end

    context 'when it is not a development shop' do
      before do
        allow(shop).to receive(:app_installation).and_return(nil)
      end

      it 'returns false' do
        allow(shop).to receive(:shopify_plan).and_return(
          double('Plan', displayName: 'Shopify Basic', partnerDevelopment: false, shopifyPlus: false)
        )
        expect(shop).not_to be_development_shop
      end
    end
  end
end
