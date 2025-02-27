# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShopifyBilling::CouponCode, type: :model do
  let(:shop) { create(:shop) }
  let(:coupon_code) { create(:coupon_code, coupon_code: 'TEST10', free_days: 30, validity: 1.month.from_now) }
  
  describe 'validations' do
    it { should validate_presence_of(:coupon_code) }
    it { should validate_uniqueness_of(:coupon_code) }
  end
  
  describe '#assign_to_shop' do
    it 'assigns the coupon to the shop' do
      expect(shop.redeemed_coupon_id).to be_nil
      
      coupon_code.assign_to_shop(shop)
      
      expect(shop.redeemed_coupon_id).to eq(coupon_code.id)
    end
  end
  
  describe '#redeem' do
    it 'increments the redeem counter' do
      expect {
        coupon_code.redeem(shop)
      }.to change(coupon_code, :redeem_counter).by(1)
    end
    
    it 'assigns the coupon to the shop' do
      coupon_code.redeem(shop)
      
      expect(shop.redeemed_coupon_id).to eq(coupon_code.id)
    end
  end
  
  describe '#valid?' do
    context 'when coupon is valid' do
      it 'returns true' do
        expect(coupon_code.valid?).to be true
      end
    end
    
    context 'when coupon has expired' do
      let(:coupon_code) { create(:coupon_code, validity: 1.day.ago) }
      
      it 'returns false' do
        expect(coupon_code.valid?).to be false
      end
    end
  end
end 