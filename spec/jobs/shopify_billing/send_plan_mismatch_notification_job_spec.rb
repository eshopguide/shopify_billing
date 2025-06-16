# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShopifyBilling::SendPlanMismatchNotificationJob, type: :job do
  describe '#perform' do
    before do
      allow(Rails.env).to receive(:production?).and_return(true)
      allow(Shop).to receive(:find_by).with(id: shop.id).and_return(shop)
    end

    context 'when shop has a plan mismatch' do
      let!(:shop) { create(:shop, plan_mismatch_since: 3.days.ago) }

      it 'sends plan mismatch notification' do
        expect(shop).to receive(:send_plan_mismatch_notification)

        described_class.new.perform(shop.id)
      end
    end

    context 'when shop does not have a plan mismatch' do
      let!(:shop) { create(:shop, plan_mismatch_since: nil) }

      it 'does not send plan mismatch notification' do
        expect(shop).not_to receive(:send_plan_mismatch_notification)

        described_class.new.perform(shop.id)
      end
    end
  end
end
