# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ShopifyBilling::ShopBilling do
  let(:shop) { Shop.create!(shopify_domain: 'test-shop.myshopify.com', shopify_token: 'token123') }
  let(:billing_plan) { ShopifyBilling::BillingPlan.create!(name: 'Test Plan', price: 19.99) }

  describe '#feature_enabled?' do
    it 'returns false when no billing plan is attached' do
      expect(shop.feature_enabled?('some_feature')).to be false
    end

    it 'returns true when the feature is included in the plan features' do
      billing_plan.update(features: ['some_feature'])
      shop.update(billing_plan: billing_plan, billing_activated: true)

      expect(shop.feature_enabled?('some_feature')).to be true
    end
  end

  describe '#development_shop?' do
    let(:shop) { create(:shop) }

    context 'when it is a development shop' do
      it 'returns true' do
        allow(shop).to receive(:shopify_plan).and_return(
          double('Plan', displayName: 'Shopify Plus Partner Sandbox', partnerDevelopment: true, shopifyPlus: true)
        )

        expect(shop.development_shop?).to be_truthy
      end
    end

    context 'when it is not a development shop' do
      it 'returns false' do
        allow(shop).to receive(:shopify_plan).and_return(
          double('Plan', displayName: 'Shopify Basic', partnerDevelopment: false, shopifyPlus: false)
        )
        expect(shop.development_shop?).to be_falsey
      end
    end
  end
end
