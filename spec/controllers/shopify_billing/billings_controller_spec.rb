# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShopifyBilling::BillingsController do
  routes { ShopifyBilling::Engine.routes }

  let(:shop) { create(:shop) }
  let(:plans) { { 'recurring' => [{ id: 1, name: 'Basic Plan' }] } }

  before do
    mock_shopify_session(shop)
    allow(controller).to receive(:set_current_shop).and_call_original
    allow(controller).to receive(:current_shopify_session).and_return(create_shopify_session(shop.shopify_domain))
    allow(Shop).to receive(:find_by).with(shopify_domain: shop.shopify_domain).and_return(shop)
  end

  describe 'GET #show' do
    before do
      allow(ShopifyBilling::SelectAvailableBillingPlansService).to receive(:call).and_return(plans)
    end

    it 'returns available billing plans' do
      get :show
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq(plans.as_json)
    end

    it 'passes coupon code to the service when provided' do
      allow(ShopifyBilling::SelectAvailableBillingPlansService).to receive(:call)
        .with(shop: shop, coupon_code: 'ABC123')
        .and_return(plans)

      get :show, params: { coupon_code: 'ABC123' }
      expect(response).to have_http_status(:ok)
    end

    it 'sets the current shop' do
      expect(controller).to receive(:set_current_shop)
      get :show
    end
  end

  describe 'POST #create_charge' do
    let(:billing_plan) { create(:billing_plan) }
    let(:charge) { double('Charge', confirmation_url: 'https://example.com/confirm') }

    before do
      allow(ShopifyBilling::CreateChargeService).to receive(:call).and_return(charge)
    end

    it 'creates a charge and returns confirmation URL' do
      post :create_charge, params: { plan_id: billing_plan.id }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq({
                                           'success' => true,
                                           'confirmation_url' => 'https://example.com/confirm'
                                         })
    end

    it 'passes coupon code to the service when provided' do
      allow(ShopifyBilling::CreateChargeService).to receive(:call)
        .with(
          shop: shop,
          billing_plan_id: billing_plan.id.to_s,
          coupon_code: 'ABC123',
          host: anything
        )
        .and_return(charge)

      post :create_charge, params: { plan_id: billing_plan.id, coupon_code: 'ABC123' }
      expect(response).to have_http_status(:ok)
    end

    it 'returns error when charge creation fails' do
      allow(ShopifyBilling::CreateChargeService).to receive(:call).and_return(nil)

      post :create_charge, params: { plan_id: billing_plan.id }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq({ 'success' => false })
    end

    it 'requires plan_id parameter' do
      expect do
        post :create_charge
      end.to raise_error(ActionController::ParameterMissing)
    end
  end
end
