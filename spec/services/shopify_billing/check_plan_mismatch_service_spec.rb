# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShopifyBilling::CheckPlanMismatchService, type: :service do
  let(:shop) { create(:shop, plan_mismatch_since: nil) }
  let(:service) { described_class.new(shop:) }

  describe '#call' do
    context 'when shop is nil' do
      let(:shop) { nil }

      it 'does nothing' do
        expect(ShopifyBilling::SendPlanMismatchNotificationJob).not_to receive(:perform_later)
        service.call
      end
    end

    context 'when plan_mismatch_since is already set' do
      let!(:shop) { create(:shop, plan_mismatch_since: 3.days.ago) }

      it 'does not update the shop or enqueue any jobs' do
        expect(shop).not_to receive(:update!)
        expect(ShopifyBilling::SendPlanMismatchNotificationJob).not_to receive(:perform_later)
        expect(ShopifyBilling::ResetBillingPlanJob).not_to receive(:perform_in)
        service.call
      end
    end

    context 'when shop is a development shop with a development plan' do
      let(:billing_plan) { create(:billing_plan, development_plan: true) }

      before do
        allow(shop).to receive(:development_shop?).and_return(true)
        allow(shop).to receive(:billing_plan).and_return(billing_plan)
      end

      it 'does not update the shop or enqueue any jobs' do
        expect(shop).not_to receive(:update!)
        expect(ShopifyBilling::SendPlanMismatchNotificationJob).not_to receive(:perform_later)
        expect(ShopifyBilling::ResetBillingPlanJob).not_to receive(:perform_in)
        service.call
      end
    end

    context 'when shop is not a development shop but on a development plan' do
      let(:billing_plan) { create(:billing_plan, development_plan: true) }
      let(:shop) { create(:shop) }

      before do
        allow(shop).to receive(:development_shop?).and_return(false)
        allow(shop).to receive(:billing_plan).and_return(billing_plan)
      end

      it 'updates the shop with plan_mismatch_since and enqueues the jobs' do
        expect(shop).to receive(:update!).with(plan_mismatch_since: kind_of(DateTime))
        expect(ShopifyBilling::SendPlanMismatchNotificationJob).to receive(:perform_later)
        expect(ShopifyBilling::ResetBillingPlanJob).to receive_message_chain(:set, :perform_later)

        service.call
      end
    end

    context 'when production shop is on a non-development plan' do
      let(:billing_plan) { create(:billing_plan, development_plan: false) }
      let(:shop) { create(:shop) }

      before do
        allow(shop).to receive(:development_shop?).and_return(false)
        allow(shop).to receive(:billing_plan).and_return(billing_plan)
      end

      it 'does not update the shop or enqueue any jobs' do
        expect(shop).not_to receive(:update!)
        expect(ShopifyBilling::SendPlanMismatchNotificationJob).not_to receive(:perform_later)
        expect(ShopifyBilling::ResetBillingPlanJob).not_to receive(:perform_in)
        service.call
      end
    end
  end
end
