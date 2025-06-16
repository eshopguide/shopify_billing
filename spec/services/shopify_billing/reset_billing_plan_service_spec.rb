# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShopifyBilling::ResetBillingPlanService, type: :service do
  let(:shop) { create(:shop) }
  let(:service) { described_class.new(shop:) }

  before do
    allow(ShopifyAPI::RecurringApplicationCharge).to receive(:current).and_return(nil)
  end

  describe '#call' do
    context 'when shop is nil' do
      let(:service) { described_class.new(shop: nil) }

      it 'does nothing' do
        expect(shop).not_to receive(:update!)
      end
    end

    context 'when shop is present' do
      let(:shop) { create(:shop, plan_mismatch_since: 3.days.ago, trial_ends_on: '1970-01-01') }

      it 'resets plan_mismatch_since' do
        service.call

        expect(shop.reload.plan_mismatch_since).to be_falsey
      end

      it 'resets charges cache' do
        expect(shop).to receive(:reset_app_installation_cache)
        service.call
      end

      context 'when shop has a recurring charge' do
        let(:recurring_charge) { double(id: '123', status: 'ACTIVE') }

        it 'cancels the recurring charge' do
          allow(ShopifyAPI::RecurringApplicationCharge).to receive(:current).and_return(recurring_charge)
          expect(ShopifyAPI::RecurringApplicationCharge).to receive(:delete).with(id: recurring_charge.id)

          service.call
        end
      end

      context 'when shop does not have a recurring charge' do
        it 'does not cancel the recurring charge' do
          allow(ShopifyAPI::RecurringApplicationCharge).to receive(:current).and_return(nil)
          expect(ShopifyAPI::RecurringApplicationCharge).not_to receive(:delete)

          service.call
        end
      end
    end
  end
end
