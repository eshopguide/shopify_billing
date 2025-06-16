# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShopifyBilling::ResetBillingPlanJob, type: :job do
  describe '#perform' do
    context 'when plan_mismatch_since is set' do
      let(:shop) { create(:shop, plan_mismatch_since: DateTime.now) }

      it 'calls the ResetBillingPlanService' do
        expect(ShopifyBilling::ResetBillingPlanService).to receive(:call).with(shop:)
        described_class.new.perform(shop.id)
      end
    end

    context 'when shop plan is not mismatched' do
      let(:shop) { create(:shop, plan_mismatch_since: nil) }

      it 'does not call the ResetBillingPlanService' do
        expect(ShopifyBilling::ResetBillingPlanService).not_to receive(:call)
        described_class.new.perform(shop.id)
      end
    end
  end
end
