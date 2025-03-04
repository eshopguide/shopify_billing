# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShopifyBilling::CreateChargeService do
  let!(:shop) { create(:shop) }
  let(:billing_plan) { create(:billing_plan) }
  let(:coupon) { create(:one_time_coupon_code, coupon_code: 'ABC123') }
  let(:host) { 'some-host' }
  let(:one_time_charge) do
    double('ShopifyAPI::ApplicationCharge', id: 123, status: 'active', test: false, current_period_end: nil)
  end
  let(:recurring_charge) do
    double('ShopifyAPI::RecurringApplicationCharge', id: 123, status: 'active', test: false,
                                                     current_period_end: 1.month.from_now)
  end
  let(:service) do
    described_class.new(shop:, billing_plan_id: billing_plan.id, host:, coupon_code: coupon&.coupon_code)
  end

  before do
    allow(ShopifyBilling::BillingPlan).to receive(:find).with(billing_plan.id).and_return(billing_plan)
    allow(shop).to receive(:billing_plan).and_return(billing_plan)
  end

  describe '#call' do
    context 'when logging plan click' do
      let(:current_time) { Time.current }

      before do
        allow(Time).to receive(:current).and_return(current_time)
        allow(billing_plan).to receive(:price_for_shop).with(shop).and_return(29.99)
        allow(service).to receive(:report_event)
      end

      it 'logs the plan click event with correct parameters' do
        expect(service).to receive(:report_event).with(
          event_name: 'plan_click',
          event_type: CentralEventLogger::EventTypes::ENGAGEMENT,
          customer_myshopify_domain: shop.shopify_domain,
          event_value: billing_plan.name,
          payload: {
            plan_price: 29.99
          },
          timestamp: current_time
        )

        service.call
      end

      it 'creates a charge' do
        allow(billing_plan).to receive_messages(recurring?: false, one_time?: true)

        allow(ShopifyAPI::ApplicationCharge).to receive(:new)
          .with(from_hash: kind_of(Hash))
          .and_return(one_time_charge)
        expect(one_time_charge).to receive(:save!)

        expect { service.call }.not_to raise_error
      end
    end

    context 'when shop is nil' do
      let(:shop) { nil }

      it 'does not create a charge' do
        expect(ShopifyAPI::ApplicationCharge).not_to receive(:new)
        expect(ShopifyAPI::RecurringApplicationCharge).not_to receive(:new)
        expect(service.call).to be_nil
      end
    end

    context 'when billing_plan is nil' do
      before do
        allow(ShopifyBilling::BillingPlan).to receive(:find).with(billing_plan.id).and_return(nil)
      end

      it 'does not create a charge' do
        expect(ShopifyAPI::ApplicationCharge).not_to receive(:new)
        expect(ShopifyAPI::RecurringApplicationCharge).not_to receive(:new)
        expect(service.call).to be_nil
      end
    end

    context 'when host is nil' do
      let(:host) { nil }

      it 'does not create a charge' do
        expect(ShopifyAPI::ApplicationCharge).not_to receive(:new)
        expect(ShopifyAPI::RecurringApplicationCharge).not_to receive(:new)
        expect(service.call).to be_nil
      end
    end

    context 'when billing plan is recurring' do
      before do
        allow(billing_plan).to receive(:recurring?).and_return(true)
      end

      context 'with a valid coupon code' do
        before do
          allow(ShopifyBilling::CouponCode).to receive(:find_by).and_return(coupon)
          allow(coupon).to receive(:assign_to_shop).with(shop)
          allow(billing_plan).to receive(:apply_coupon).with(coupon)
        end

        it 'assigns the coupon to the shop and applies it to the billing plan' do
          expect(coupon).to receive(:assign_to_shop).with(shop)
          expect(billing_plan).to receive(:apply_coupon).with(coupon)
          service.call
        end

        it 'creates a recurring application charge' do
          allow(ShopifyAPI::RecurringApplicationCharge)
            .to receive(:new).with(from_hash: kind_of(Hash)).and_return(recurring_charge)
          expect(recurring_charge).to receive(:save!)

          expect { service.call }.to change(ShopifyBilling::Charge, :count).by(1)
          expect(ShopifyBilling::Charge.last.shopify_id).to eq("gid://shopify/AppSubscription/#{recurring_charge.id}")
        end
      end

      context 'without a coupon code' do
        let(:coupon) { nil }

        it 'creates a recurring application charge' do
          allow(ShopifyAPI::RecurringApplicationCharge)
            .to receive(:new).with(from_hash: kind_of(Hash)).and_return(recurring_charge)
          expect(recurring_charge).to receive(:save!)
          expect(ShopifyBilling::OneTimeCouponCode).not_to receive(:assign_to_shop)
          expect(billing_plan).not_to receive(:apply_coupon)

          service.call
        end
      end
    end

    context 'when billing plan is not recurring' do
      before do
        allow(billing_plan).to receive_messages(recurring?: false, one_time?: true)
      end

      it 'creates a one-time application charge and does not apply coupon' do
        allow(ShopifyAPI::ApplicationCharge).to receive(:new)
          .with(from_hash: kind_of(Hash))
          .and_return(one_time_charge)
        expect(one_time_charge).to receive(:save!)

        expect(ShopifyBilling::OneTimeCouponCode).not_to receive(:assign_to_shop)
        expect(billing_plan).not_to receive(:apply_coupon)

        expect { service.call }.to change(ShopifyBilling::Charge, :count).by(1)
        expect(ShopifyBilling::Charge.last.shopify_id).to eq("gid://shopify/AppPurchaseOneTime/#{one_time_charge.id}")
      end
    end
  end

  describe '#charge_attributes' do
    context 'when TEST_CHARGE is true' do
      before do
        stub_const('ENV', ENV.to_hash.merge('TEST_CHARGE' => 'true'))
      end

      context 'when development billing plan' do
        let(:billing_plan) { create(:billing_plan, development_plan: true) }

        it 'creates a test charge' do
          charge_attributes = service.send(:charge_attributes)

          expect(charge_attributes[:test]).to eq(true)
        end
      end

      context 'when production billing plan' do
        let(:billing_plan) { create(:billing_plan, development_plan: false) }

        it 'creates a production charge' do
          charge_attributes = service.send(:charge_attributes)

          expect(charge_attributes[:test]).to eq(true)
        end
      end
    end

    context 'when TEST_CHARGE is false' do
      before do
        stub_const('ENV', ENV.to_hash.merge('TEST_CHARGE' => 'false'))
      end

      context 'when development billing plan' do
        let(:billing_plan) { create(:billing_plan, development_plan: true) }

        it 'creates a test charge' do
          charge_attributes = service.send(:charge_attributes)

          expect(charge_attributes[:test]).to eq(true)
        end
      end

      context 'when production billing plan' do
        let(:billing_plan) { create(:billing_plan, development_plan: false) }

        it 'creates a production charge' do
          charge_attributes = service.send(:charge_attributes)

          expect(charge_attributes[:test]).to eq(false)
        end
      end

      context 'when internal test shop' do
        let(:shop) { create(:shop, internal_test_shop: true) }

        it 'creates a test charge' do
          charge_attributes = service.send(:charge_attributes)

          expect(charge_attributes[:test]).to eq(true)
        end
      end
    end
  end
end
