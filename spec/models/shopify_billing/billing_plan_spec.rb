# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShopifyBilling::BillingPlan do
  describe '#recurring?' do
    let(:recurring_plan) { create(:billing_plan, plan_type: 'recurring') }
    let(:one_time_plan) { create(:billing_plan, plan_type: 'one_time') }

    it 'returns true/false' do
      expect(recurring_plan.recurring?).to eq(true)
      expect(one_time_plan.recurring?).to eq(false)
    end
  end

  describe '#one_time?' do
    let(:recurring_plan) { create(:billing_plan, plan_type: 'recurring') }
    let(:one_time_plan) { create(:billing_plan, plan_type: 'one_time') }

    it 'returns true/false' do
      expect(recurring_plan.one_time?).to eq(false)
      expect(one_time_plan.one_time?).to eq(true)
    end
  end

  describe '#trial_days_for_shop' do
    let(:billing_plan) { create(:billing_plan, plan_type: 'recurring') }
    let(:shop) { create(:shop) }

    context 'when plan_type is one_time' do
      before { allow(billing_plan).to receive(:plan_type).and_return('one_time') }

      it 'returns 0' do
        expect(billing_plan.trial_days_for_shop(shop)).to eq(0)
      end
    end

    context 'when coupon with free days is present' do
      let(:shop) { create(:shop, trial_ends_on: '1990-01-01') }
      let(:coupon) { create(:coupon_code, free_days: 15) }

      before do
        billing_plan.apply_coupon(coupon)
      end

      it 'always returns the number of free days from the coupon' do
        expect(billing_plan.trial_days_for_shop(shop)).to eq(15)
      end

      context 'when shop has a trial end date' do
        before do
          allow(shop).to receive(:trial_ends_on).and_return(Time.zone.today + 5.days)
        end

        it 'still returns the coupon free days' do
          expect(billing_plan.trial_days_for_shop(shop)).to eq(coupon.free_days)
        end
      end
    end

    context 'when shop has a trial end date' do
      before do
        allow(shop).to receive(:trial_ends_on).and_return(Time.zone.today + 5.days)
      end

      it 'returns the remaining trial days' do
        expect(billing_plan.trial_days_for_shop(shop)).to eq(5)
      end

      it 'returns 0 if trial has ended' do
        allow(shop).to receive(:trial_ends_on).and_return(Time.zone.today - 5.days)
        expect(billing_plan.trial_days_for_shop(shop)).to eq(0)
      end
    end
  end

  describe '#current_for_shop?' do
    let(:shop) { create(:shop) }

    context 'with recurring plan' do
      let(:billing_plan) { create(:billing_plan, plan_type: 'recurring') }

      context 'when shop has this billing plan' do
        before do
          allow(shop).to receive(:billing_plan).and_return(billing_plan)
        end

        it 'returns true' do
          expect(billing_plan.current_for_shop?(shop)).to eq(true)
        end
      end

      context 'when shop has a different billing plan' do
        let(:other_billing_plan) { create(:billing_plan) }
        
        before do
          allow(shop).to receive(:billing_plan).and_return(other_billing_plan)
        end

        it 'returns false' do
          expect(billing_plan.current_for_shop?(shop)).to eq(false)
        end
      end

      context 'when shop has no billing plan' do
        before do
          allow(shop).to receive(:billing_plan).and_return(nil)
        end

        it 'returns false' do
          expect(billing_plan.current_for_shop?(shop)).to eq(false)
        end
      end
    end

    context 'with one time plan' do
      let(:billing_plan) { create(:billing_plan, plan_type: 'one_time') }

      it 'always returns false' do
        expect(billing_plan.current_for_shop?(shop)).to eq(false)
      end
    end
  end

  describe '#discount_for_shop' do
    let(:shop) { create(:shop, discount_percent: 10, import_discount_percent: 20) }

    context 'with recurring plan' do
      let(:billing_plan) { create(:billing_plan, plan_type: 'recurring') }

      it 'returns the correct discount' do
        expect(billing_plan.discount_for_shop(shop)).to eq(10)
      end
    end

    context 'with one_time plan' do
      let(:billing_plan) { create(:billing_plan, plan_type: 'one_time') }

      it 'returns the correct discount' do
        expect(billing_plan.discount_for_shop(shop)).to eq(20)
      end
    end
  end

  describe '#price_for_shop' do
    context 'with recurring discount' do
      let(:billing_plan) { create(:billing_plan, plan_type: 'recurring', price: 1000) }

      context 'with percent discount' do
        let(:shop) { create(:shop, discount_percent: 10) }

        it 'calculates the correct price' do
          expect(billing_plan.price_for_shop(shop)).to eq(900)
        end
      end

      context 'with discount above 100%' do
        let(:shop) { create(:shop, discount_percent: 120) }

        it 'calculates the correct price' do
          expect(billing_plan.price_for_shop(shop)).to eq(1)
        end
      end

      context 'with discount has no influence on one_time billing plan' do
        let(:billing_plan) { create(:billing_plan, plan_type: 'one_time', price: 1000) }
        let(:shop) { create(:shop, discount_percent: 120) }

        it 'calculates the correct price' do
          expect(billing_plan.price_for_shop(shop)).to eq(billing_plan.price)
        end
      end
    end

    context 'with one_time discount' do
      let(:billing_plan) { create(:billing_plan, plan_type: 'one_time', price: 1000) }

      context 'with percent discount' do
        let(:shop) { create(:shop, import_discount_percent: 10) }

        it 'calculates the correct price' do
          expect(billing_plan.price_for_shop(shop)).to eq(900)
        end
      end

      context 'with discount above 100%' do
        let(:shop) { create(:shop, import_discount_percent: 120) }

        it 'calculates the correct price' do
          expect(billing_plan.price_for_shop(shop)).to eq(1)
        end
      end

      context 'with discount has no influence on recurring billing plan' do
        let(:billing_plan) { create(:billing_plan, plan_type: 'recurring', price: 1000) }
        let(:shop) { create(:shop, import_discount_percent: 120) }

        it 'calculates the correct price' do
          expect(billing_plan.price_for_shop(shop)).to eq(billing_plan.price)
        end
      end
    end
  end
end
