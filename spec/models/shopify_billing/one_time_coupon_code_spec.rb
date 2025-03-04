# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShopifyBilling::OneTimeCouponCode do
  let(:one_time_coupon_code) { create(:one_time_coupon_code) }
  let(:shop) { create(:shop) }

  describe '#assign_to_shop' do
    context 'when coupon is valid' do
      before do
        allow(one_time_coupon_code).to receive_messages(valid?: true, coupon_valid?: true)
      end

      it 'assigns the coupon to the shop' do
        expect { one_time_coupon_code.assign_to_shop(shop) }
          .to change(one_time_coupon_code, :shop_id).to(shop.id)
      end
    end

    context 'when coupon is invalid' do
      before do
        allow(one_time_coupon_code).to receive(:valid?).and_return(false)
      end

      it 'raises an InvalidCouponError' do
        expect { one_time_coupon_code.assign_to_shop(shop) }
          .to raise_error(ShopifyBilling::InvalidCouponError)
      end
    end
  end

  describe '#redeem' do
    context 'when coupon is valid' do
      before do
        allow(one_time_coupon_code).to receive_messages(valid?: true, coupon_valid?: true)
        one_time_coupon_code.redeem_counter = 1
      end

      it 'marks the coupon as redeemed' do
        expect { one_time_coupon_code.redeem(shop) }
          .to change(one_time_coupon_code, :redeemed).from(false).to(true)
      end

      it 'decrements the redeem_counter' do
        expect { one_time_coupon_code.redeem(shop) }
          .to change(one_time_coupon_code, :redeem_counter).by(-1)
      end
    end

    context 'when coupon is invalid' do
      before do
        allow(one_time_coupon_code).to receive(:valid?).and_return(false)
      end

      it 'raises an InvalidCouponError' do
        expect { one_time_coupon_code.redeem(shop) }
          .to raise_error(ShopifyBilling::InvalidCouponError)
      end
    end
  end

  describe '#coupon_valid?' do
    let(:other_shop) { create(:shop) }

    before do
      one_time_coupon_code.redeem_counter = 1
    end

    context 'when coupon is not assigned to any shop' do
      it 'returns true' do
        expect(one_time_coupon_code.coupon_valid?(shop)).to be true
      end
    end

    context 'when coupon is assigned to the given shop' do
      before do
        one_time_coupon_code.shop = shop
      end

      it 'returns true' do
        expect(one_time_coupon_code.coupon_valid?(shop)).to be true
      end
    end

    context 'when coupon is assigned to a different shop' do
      before do
        one_time_coupon_code.shop = other_shop
      end

      it 'returns false' do
        expect(one_time_coupon_code.coupon_valid?(shop)).to be false
      end
    end

    context 'when redeem_counter is zero' do
      before do
        one_time_coupon_code.redeem_counter = 0
      end

      it 'returns false' do
        expect(one_time_coupon_code.coupon_valid?(shop)).to be false
      end
    end
  end
end
