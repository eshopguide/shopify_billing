# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShopifyBilling::BillingPlan, type: :model do
  describe 'associations' do
    it { should have_many(:charges) }
  end

  describe 'scopes' do
    it 'has a free scope' do
      free_plan = ShopifyBilling::BillingPlan.create!(
        name: 'Free Plan',
        short_name: 'FreePlan',
        price: 0
      )

      paid_plan = ShopifyBilling::BillingPlan.create!(
        name: 'Paid Plan',
        short_name: 'PaidPlan',
        price: 19.99
      )

      expect(ShopifyBilling::BillingPlan.free).to eq(free_plan)
    end
  end

  describe '#recurring?' do
    it 'returns true when plan_type is recurring' do
      plan = ShopifyBilling::BillingPlan.new(plan_type: 'recurring')
      expect(plan.recurring?).to be true
    end

    it 'returns false when plan_type is not recurring' do
      plan = ShopifyBilling::BillingPlan.new(plan_type: 'one_time')
      expect(plan.recurring?).to be false
    end
  end

  describe '#one_time?' do
    it 'returns true when plan_type is one_time' do
      plan = ShopifyBilling::BillingPlan.new(plan_type: 'one_time')
      expect(plan.one_time?).to be true
    end

    it 'returns false when plan_type is not one_time' do
      plan = ShopifyBilling::BillingPlan.new(plan_type: 'recurring')
      expect(plan.one_time?).to be false
    end
  end

  describe '#price_for_shop' do
    let(:plan) { ShopifyBilling::BillingPlan.new(price: 20.0) }

    it 'applies discount from the shop' do
      shop = double('Shop', discount_percent: 10, import_discount_percent: 0)
      allow(plan).to receive(:recurring?).and_return(true)

      expect(plan.price_for_shop(shop)).to eq(18.0) # 20 - 10%
    end

    it 'applies import discount for one-time plans' do
      shop = double('Shop', discount_percent: 0, import_discount_percent: 20)
      allow(plan).to receive(:recurring?).and_return(false)

      expect(plan.price_for_shop(shop)).to eq(16.0) # 20 - 20%
    end

    it 'never returns less than 1' do
      shop = double('Shop', discount_percent: 100, import_discount_percent: 100)

      expect(plan.price_for_shop(shop)).to eq(1.0)
    end
  end
end