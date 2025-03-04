# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShopifyBilling::SelectAvailableBillingPlansService do
  describe '#call' do
    let!(:shop) { create(:shop) }
    let!(:current_plan) { create(:billing_plan) }
    let!(:recurring_plan) { create(:billing_plan, plan_type: 'recurring') }
    let!(:one_time_plan) { create(:billing_plan, plan_type: 'one_time') }
    let(:coupon_code) { nil }
    let(:service) { described_class.new(shop:, coupon_code:) }

    before do
      allow(ShopifyBilling::BillingPlan)
        .to receive_message_chain(:where, :order)
        .and_return([current_plan, recurring_plan, one_time_plan])
      allow(shop).to receive_messages(development_shop?: false, billing_plan: current_plan)
      allow(current_plan).to receive(:current_for_shop?).with(shop).and_return(true)
      allow(recurring_plan).to receive(:current_for_shop?).with(shop).and_return(false)
      allow(one_time_plan).to receive(:current_for_shop?).with(shop).and_return(false)
    end

    context 'when no coupon code is provided' do
      it 'returns the grouped billing plans with correct attributes' do
        result = service.call
        available_plans = result.values.flatten

        expect(result.keys).to include('recurring', 'one_time')
        expect(available_plans.size).to eq(3)
        expect(available_plans.find { |plan| plan[:is_current_plan] == true }).to be_truthy
      end

      context 'when the shop is a development shop' do
        let(:recurring_plan) { create(:billing_plan, plan_type: 'recurring', available_for_development_shop: true) }

        it 'only returns development plans' do
          allow(shop).to receive(:development_shop?).and_return(true)

          result = service.call
          available_plans = result.values.flatten
          expect(available_plans.size).to eq(1)
        end
      end

      context 'when the shop is a production shop' do
        it 'only returns production plans' do
          allow(shop).to receive(:development_shop?).and_return(false)

          result = service.call
          available_plans = result.values.flatten
          expect(available_plans.size).to eq(3)
        end
      end
    end

    context 'when a valid coupon code is provided' do
      let(:coupon_code) { 'ABC123' }
      let(:coupon) { create(:coupon_code, coupon_code:) }

      before do
        allow(ShopifyBilling::CouponCode).to receive(:find_by!).with(coupon_code:).and_return(coupon)
        allow(coupon).to receive(:coupon_valid?).with(shop).and_return(true)
        allow(ShopifyBilling::BillingPlan).to receive(:apply_coupon).with(coupon)
      end

      it 'applies the coupon to recurring billing plans' do
        expect(recurring_plan).to receive(:apply_coupon).with(coupon)
        expect(one_time_plan).not_to receive(:apply_coupon)

        service.call
      end
    end

    context 'when an invalid coupon code is provided' do
      let(:coupon_code) { 'WROONG' }

      it 'raises an ActiveRecord::RecordNotFound error' do
        expect { service.call }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when the coupon is invalid for the shop' do
      let(:coupon_code) { 'ABC123' }
      let(:coupon) { create(:coupon_code, coupon_code:) }

      before do
        allow(ShopifyBilling::CouponCode).to receive(:find_by!).with(coupon_code:).and_return(coupon)
        allow(coupon).to receive(:coupon_valid?).with(shop).and_return(false)
      end

      it 'raises an InvalidCouponError' do
        expect { service.call }.to raise_error(ShopifyBilling::InvalidCouponError)
      end
    end
  end
end
