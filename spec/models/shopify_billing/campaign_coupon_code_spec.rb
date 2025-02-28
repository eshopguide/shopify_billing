# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShopifyBilling::CampaignCouponCode, type: :model do
  let(:campaign_coupon_code) { create(:campaign_coupon_code) }
  let(:shop) { create(:shop) }

  describe '#assign_to_shop' do
    it 'does not perform any action' do
      expect { campaign_coupon_code.assign_to_shop(shop) }.not_to(change { campaign_coupon_code })
    end
  end

  describe '#redeem' do
    context 'when coupon is valid' do
      before do
        allow(campaign_coupon_code).to receive(:coupon_valid?).and_return(true)
        campaign_coupon_code.redeem_counter = 2
        campaign_coupon_code.save!
      end

      it 'decrements the redeem_counter' do
        expect { campaign_coupon_code.redeem(shop) }.to change { campaign_coupon_code.reload.redeem_counter }.by(-1)
      end

      it 'updates the shop with the redeemed coupon id' do
        expect { campaign_coupon_code.redeem(shop) }.to change {
          shop.reload.redeemed_coupon_id
        }.to(campaign_coupon_code.id)
      end
    end

    context 'when coupon is invalid' do
      before do
        allow(campaign_coupon_code).to receive(:coupon_valid?).and_return(false)
      end

      it 'raises an InvalidCouponError' do
        expect { campaign_coupon_code.redeem(shop) }.to raise_error(ShopifyBilling::InvalidCouponError)
      end
    end
  end

  describe '#coupon_valid?' do
    let(:campaign_coupon_code) { create(:campaign_coupon_code) }

    context 'when validity is in the future and redeem_counter is positive' do
      before do
        campaign_coupon_code.update(validity: 1.day.from_now, redeem_counter: 1)
      end

      it 'returns true' do
        expect(campaign_coupon_code.send(:coupon_valid?, shop)).to be true
      end
    end

    context 'when validity is in the past' do
      before do
        campaign_coupon_code.update(validity: 1.day.ago, redeem_counter: 1)
      end

      it 'returns false' do
        expect(campaign_coupon_code.send(:coupon_valid?, shop)).to be false
      end
    end

    context 'when redeem_counter is zero' do
      before do
        campaign_coupon_code.update(validity: 1.day.from_now, redeem_counter: 0)
      end

      it 'returns false' do
        expect(campaign_coupon_code.send(:coupon_valid?, shop)).to be false
      end
    end
  end
end