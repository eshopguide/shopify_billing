# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShopifyBilling::HandleChargeService do
  let(:shop) { create(:shop) }
  let(:shop_id) { shop.id }
  let(:billing_plan) { create(:billing_plan, name: 'Pro Plan', price: 19.99) }
  let(:charge_id) { '123456' }
  let(:coupon_code) { 'ABC123' }
  let(:coupon) { create(:one_time_coupon_code, coupon_code: 'ABC123') }
  let(:campaign_coupon) { create(:campaign_coupon_code, coupon_code: 'CAM123') }
  let(:valid_token) { 'valid_token' }
  let(:previous_plan) { nil }
  let(:service) do
    allow(Shop).to receive(:find).and_return(shop)
    described_class.new(shop_id:, charge_id:, billing_plan_id: billing_plan.id, coupon_code:, token: valid_token)
  end

  before do
    allow(service).to receive(:verification_token).and_return(valid_token)
    allow(ShopifyBilling::CouponCode).to receive(:find_by).and_return(coupon)
    allow(service).to receive(:report_event)
    allow(shop).to receive(:billing_plan).and_return(previous_plan)
  end

  describe '#call' do
    context 'when inputs are invalid' do
      it 'returns nil if charge_id is nil' do
        service = described_class.new(shop_id:, charge_id: nil, billing_plan_id: billing_plan.id,
                                      coupon_code:, token: valid_token)
        expect(service.call).to be_nil
      end

      it 'returns nil if billing_plan is nil' do
        expect do
          described_class.new(shop_id:, charge_id:, billing_plan_id: nil, coupon_code:,
                              token: valid_token)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when charge is active' do
      let(:charge) { double('Charge', status: 'active', trial_ends_on: 1.week.from_now, id: '12345', price: 19.99) }

      before do
        allow(service).to receive(:find_charge).and_return(charge)
      end

      it 'clears the charges cache' do
        expect(shop).to receive(:reset_app_installation_cache)
        service.call
      end

      context 'with a recurring plan' do
        let(:previous_plan) { nil }
        let(:billing_plan) { create(:billing_plan, plan_type: 'recurring', name: 'Pro Plan', price: 19.99) }

        context 'when activating first paid plan (from free plan)' do
          let(:shop) { create(:shop) }

          it 'logs the activation as new' do
            allow(shop).to receive(:save!)

            expect(service).to receive(:report_event).with(
              hash_including(
                event_name: 'plan_activation',
                event_type: 'conversion',
                customer_myshopify_domain: shop.shopify_domain,
                event_value: 'Pro Plan',
                payload: hash_including(
                  change_type: 'new',
                  price_at_activation: 19.99
                )
              )
            )

            service.call
          end
        end

        context 'when upgrading from a lower plan' do
          let!(:previous_plan) { create(:billing_plan, name: 'Basic Plan', price: 9.99) }
          let!(:shop) { create(:shop) }

          it 'logs the activation as upgrade' do
            allow(shop).to receive(:save!)

            expect(service).to receive(:report_event).with(
              hash_including(
                event_name: 'plan_activation',
                event_type: 'conversion',
                customer_myshopify_domain: shop.shopify_domain,
                event_value: 'Pro Plan',
                payload: hash_including(
                  change_type: 'upgrade',
                  price_at_activation: 19.99
                )
              )
            )

            service.call
          end
        end

        it 'activates the billing plan and redeems the coupon' do
          expect(coupon).to receive(:redeem).with(shop)
          expect(shop).to receive(:save!)

          service.call
        end

        context 'when shop has a plan mismatch' do
          let(:shop) { create(:shop, plan_mismatch_since: 1.day.ago) }

          it 'resets plan_mismatch_since' do
            service.call

            expect(shop.reload.plan_mismatch_since).to be_nil
          end
        end
      end

      context 'with a one-time plan' do
        let(:billing_plan) { create(:billing_plan, plan_type: 'one_time', name: 'Import Plan', price: 19.99) }

        it 'logs the one-time purchase' do
          allow(shop).to receive(:after_activate_one_time_purchase).and_return(true)

          expect(service).to receive(:report_event).with(
            hash_including(
              event_name: 'one_time_purchase',
              event_type: 'conversion',
              customer_myshopify_domain: shop.shopify_domain,
              event_value: 'Import Plan',
              payload: hash_including(
                change_type: 'new',
                price_at_activation: 19.99
              )
            )
          )

          service.call
        end
      end
    end
  end

  describe '#find_charge' do
    context 'with a recurring plan' do
      let(:billing_plan) { create(:billing_plan, plan_type: 'recurring') }

      it 'finds a RecurringApplicationCharge' do
        expect(ShopifyAPI::RecurringApplicationCharge).to receive(:find).with(id: charge_id)
        service.find_charge
      end
    end

    context 'with a one-time plan' do
      let(:billing_plan) { create(:billing_plan, plan_type: 'one_time') }

      it 'finds an ApplicationCharge' do
        expect(ShopifyAPI::ApplicationCharge).to receive(:find).with(id: charge_id)
        service.find_charge
      end
    end
  end
end
