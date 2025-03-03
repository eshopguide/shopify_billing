# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShopifyBilling::BillingCallbacksController, type: :controller do
  routes { ShopifyBilling::Engine.routes }

  let(:shop) { create(:shop) }
  let(:billing_plan) { create(:billing_plan) }
  let(:charge_id) { '123456' }
  let(:token) { 'valid_token' }
  let(:coupon_code) { 'ABC123' }

  describe 'GET #handle_charge' do
    before do
      allow(ShopifyBilling::HandleChargeService).to receive(:call).and_return('activated')
      allow(controller).to receive(:redirect_to_admin)
    end

    it 'calls the HandleChargeService with correct parameters' do
      expect(ShopifyBilling::HandleChargeService).to receive(:call).with(
        shop_id: shop.id.to_s,
        charge_id: charge_id,
        billing_plan_id: billing_plan.id.to_s,
        coupon_code: coupon_code,
        token: token
      ).and_return('activated')

      get :handle_charge, params: {
        shop_id: shop.id,
        charge_id: charge_id,
        billing_plan_id: billing_plan.id,
        coupon_code: coupon_code,
        token: token
      }
    end

    it 'redirects to admin with the result status' do
      expect(controller).to receive(:redirect_to_admin).with(nil, 'activated')

      get :handle_charge, params: {
        shop_id: shop.id,
        charge_id: charge_id,
        billing_plan_id: billing_plan.id,
        token: token
      }
    end

    it 'requires shop_id parameter' do
      expect {
        get :handle_charge, params: {
          charge_id: charge_id,
          billing_plan_id: billing_plan.id,
          token: token
        }
      }.to raise_error(ActionController::ParameterMissing)
    end

    it 'requires charge_id parameter' do
      expect {
        get :handle_charge, params: {
          shop_id: shop.id,
          billing_plan_id: billing_plan.id,
          token: token
        }
      }.to raise_error(ActionController::ParameterMissing)
    end

    it 'requires billing_plan_id parameter' do
      expect {
        get :handle_charge, params: {
          shop_id: shop.id,
          charge_id: charge_id,
          token: token
        }
      }.to raise_error(ActionController::ParameterMissing)
    end

    it 'requires token parameter' do
      expect {
        get :handle_charge, params: {
          shop_id: shop.id,
          charge_id: charge_id,
          billing_plan_id: billing_plan.id
        }
      }.to raise_error(ActionController::ParameterMissing)
    end

    context 'when coupon code is provided' do
      it 'passes the coupon code to the service' do
        expect(ShopifyBilling::HandleChargeService).to receive(:call).with(
          shop_id: shop.id.to_s,
          charge_id: charge_id,
          billing_plan_id: billing_plan.id.to_s,
          coupon_code: coupon_code,
          token: token
        ).and_return('activated')

        get :handle_charge, params: {
          shop_id: shop.id,
          charge_id: charge_id,
          billing_plan_id: billing_plan.id,
          coupon_code: coupon_code,
          token: token
        }
      end
    end

    context 'when coupon code is not provided' do
      it 'passes nil as the coupon code to the service' do
        expect(ShopifyBilling::HandleChargeService).to receive(:call).with(
          shop_id: shop.id.to_s,
          charge_id: charge_id,
          billing_plan_id: billing_plan.id.to_s,
          coupon_code: nil,
          token: token
        ).and_return('activated')

        get :handle_charge, params: {
          shop_id: shop.id,
          charge_id: charge_id,
          billing_plan_id: billing_plan.id,
          token: token
        }
      end
    end

    context 'when the service returns an error status' do
      before do
        allow(ShopifyBilling::HandleChargeService).to receive(:call).and_return('error')
      end

      it 'redirects to admin with the error status' do
        expect(controller).to receive(:redirect_to_admin).with(nil, 'error')

        get :handle_charge, params: {
          shop_id: shop.id,
          charge_id: charge_id,
          billing_plan_id: billing_plan.id,
          token: token
        }
      end
    end
  end
end