# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShopifyBilling::CreateChargeService do
  let!(:shop) { create(:shop) }
  let(:billing_plan) { create(:billing_plan) }
  let(:coupon) { create(:one_time_coupon_code, coupon_code: 'ABC123') }
  let(:host) { 'some-host' }
  let(:one_time_charge) do
    OpenStruct.new(
      data: OpenStruct.new(
        appPurchaseOneTime: OpenStruct.new(
            id: "gid://shopify/AppPurchaseOneTime/123",
        ),
        confirmationUrl: 'https://some-host/confirm'
      )
    )
  end
  let(:recurring_charge) do
    OpenStruct.new(
      data: OpenStruct.new(
        appSubscription: OpenStruct.new(
          id: "gid://shopify/AppSubscription/123"
        ),
        confirmationUrl: 'https://some-host/confirm'
      )
    )
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
        expect(CreateAppSubscription).to receive(:call).and_return(recurring_charge)

        service.call
      end

      it 'creates a charge' do
        allow(billing_plan).to receive_messages(recurring?: false, one_time?: true)
        allow(AppPurchaseOneTimeCreate).to receive(:call).and_return(one_time_charge)

        expect { service.call }.not_to raise_error
      end
    end

    context 'when shop is nil' do
      let(:shop) { nil }

      it 'does not create a charge' do
        expect(AppPurchaseOneTimeCreate).not_to receive(:call)
        expect(CreateAppSubscription).not_to receive(:call)
        expect(service.call).to be_nil
      end
    end

    context 'when billing_plan is nil' do
      before do
        allow(ShopifyBilling::BillingPlan).to receive(:find).with(billing_plan.id).and_return(nil)
      end

      it 'does not create a charge' do
        expect(AppPurchaseOneTimeCreate).not_to receive(:call)
        expect(CreateAppSubscription).not_to receive(:call)
        expect(service.call).to be_nil
      end
    end

    context 'when host is nil' do
      let(:host) { nil }

      it 'does not create a charge' do
        expect(AppPurchaseOneTimeCreate).not_to receive(:call)
        expect(CreateAppSubscription).not_to receive(:call)
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
          expect(CreateAppSubscription).to receive(:call).and_return(recurring_charge)

          service.call
        end

        it 'creates a recurring application charge' do
          allow(CreateAppSubscription)
            .to receive(:call).with(variables: kind_of(Hash)).and_return(recurring_charge)

          expect { service.call }.to change(ShopifyBilling::Charge, :count).by(1)
          expect(ShopifyBilling::Charge.last.shopify_id).to eq(recurring_charge.data.appSubscription.id)
        end
      end

      context 'without a coupon code' do
        let(:coupon) { nil }

        it 'creates a recurring application charge' do
          allow(CreateAppSubscription)
            .to receive(:call).with(variables: kind_of(Hash)).and_return(recurring_charge)
          expect(ShopifyBilling::OneTimeCouponCode).not_to receive(:assign_to_shop)
          expect(billing_plan).not_to receive(:apply_coupon)

          service.call
        end
      end

      context 'when billing plan is annual' do
        let(:billing_plan) { create(:billing_plan, interval: 'ANNUAL') }

        it 'creates a recurring application charge' do
          expect(CreateAppSubscription).to receive(:call)
            .with(variables: hash_including(lineItems: [
              hash_including(
                plan: hash_including(
                  appRecurringPricingDetails: hash_including(
                    interval: 'ANNUAL'
                  )
                )
              )
            ]))
            .and_return(recurring_charge)

          service.call
        end
      end

      context 'when billing plan is monthly' do
        let(:billing_plan) { create(:billing_plan, interval: 'EVERY_30_DAYS') }

        it 'creates a recurring application charge' do
          expect(CreateAppSubscription).to receive(:call)
            .with(variables: hash_including(lineItems: [
              hash_including(
                plan: hash_including(
                  appRecurringPricingDetails: hash_including(
                    interval: 'EVERY_30_DAYS'
                  )
                )
              )
            ]))
            .and_return(recurring_charge)

          service.call
        end
      end

      context 'when billing plan is in USD' do
        let(:billing_plan) { create(:billing_plan, currency: 'USD') }

        it 'creates a recurring application charge' do
          expect(CreateAppSubscription).to receive(:call).with(variables: hash_including(lineItems: [
            hash_including(
              plan: hash_including(
                appRecurringPricingDetails: hash_including(price: hash_including(currencyCode: 'USD'))
              )
            )
          ]))
          .and_return(recurring_charge)

          service.call
        end
      end

      context 'when billing plan is in EUR' do
        let(:billing_plan) { create(:billing_plan, currency: 'EUR') }

        it 'creates a recurring application charge' do
          expect(CreateAppSubscription).to receive(:call).with(variables: hash_including(lineItems: [
            hash_including(
              plan: hash_including(
                appRecurringPricingDetails: hash_including(price: hash_including(currencyCode: 'EUR'))
              )
            )
          ]))
          .and_return(recurring_charge)

          service.call
        end
      end
    end

    context 'when billing plan is not recurring' do
      before do
        allow(billing_plan).to receive_messages(recurring?: false, one_time?: true)
      end

      it 'creates a one-time application charge and does not apply coupon' do
        allow(AppPurchaseOneTimeCreate).to receive(:call).and_return(one_time_charge)

        expect(ShopifyBilling::OneTimeCouponCode).not_to receive(:assign_to_shop)
        expect(billing_plan).not_to receive(:apply_coupon)

        expect { service.call }.to change(ShopifyBilling::Charge, :count).by(1)
        expect(ShopifyBilling::Charge.last.shopify_id).to eq(one_time_charge.data.appPurchaseOneTime.id)
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
