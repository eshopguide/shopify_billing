# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShopifyBilling::BillingsController do
  routes { ShopifyBilling::Engine.routes }

  let(:shop) { create(:shop) }
  let(:plans) { { 'recurring' => [{ id: 1, name: 'Basic Plan' }] } }

  before do
    ShopifyBilling.authenticated_controller = 'AuthenticatedController'
    allow(controller).to receive(:handle_locale)
    allow(controller).to receive(:init_shop_settings)
    allow(controller).to receive(:handle_access_scopes)
    allow(controller).to receive(:shopify_host).and_return('https://example.com')
    mock_shopify_session(shop)
    allow(controller).to receive(:set_current_shop).and_call_original
    allow(controller).to receive(:current_shopify_session).and_return(create_shopify_session(shop.shopify_domain))
    allow(Shop).to receive(:find_by).with(shopify_domain: shop.shopify_domain).and_return(shop)
    allow(@current_shop).to receive(:with_shopify_session).and_yield
  end

  describe 'POST #check_coupon' do
    context 'without code param' do
      it 'raises ParameterMissing error' do
        expect do
          post :check_coupon
        end.to raise_error(ActionController::ParameterMissing)
      end
    end

    context 'with non-existing code' do
      it 'raises RecordNotFound error' do
        expect(ShopifyBilling::CouponCode).to receive(:find_by!).with(coupon_code: 'non-existing-code')
                                                                .and_raise(ActiveRecord::RecordNotFound)

        expect do
          post :check_coupon, params: { coupon_code: 'non-existing-code' }
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'with invalid code' do
      let(:coupon) { create(:coupon_code) }

      it 'returns 404' do
        expect(ShopifyBilling::CouponCode).to receive(:find_by!).with(coupon_code: coupon.coupon_code)
                                                                .and_return(coupon)
        expect(coupon).to receive(:coupon_valid?).with(shop).and_return(false)

        post :check_coupon, params: { coupon_code: coupon.coupon_code }
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'with valid code' do
      let(:coupon) { create(:coupon_code) }

      it 'returns success' do
        expect(ShopifyBilling::CouponCode).to receive(:find_by!).with(coupon_code: coupon.coupon_code)
                                                                .and_return(coupon)
        expect(coupon).to receive(:coupon_valid?).with(shop).and_return(true)

        post :check_coupon, params: { coupon_code: coupon.coupon_code }
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body['valid']).to eq(true)
      end
    end

    context 'with new customer coupons' do
      before do
        allow(ENV).to receive(:fetch).with('NEW_CUSTOMER_COUPONS',
                                           'EshopGuide60,COMEBACK60').and_return('EshopGuide60,COMEBACK60')
      end

      %w[EshopGuide60 COMEBACK60].each do |coupon_code|
        context "with #{coupon_code} coupon" do
          let(:coupon) { create(:coupon_code, coupon_code: 'EshopGuide60') }

          context 'when the shop already has a recurring charge' do
            it 'returns 404' do
              expect(ShopifyBilling::CouponCode).to receive(:find_by!).with(coupon_code:).and_return(coupon)
              allow(ShopifyAPI::RecurringApplicationCharge).to receive(:current).and_return(double(id: '123',
                                                                                                   status: 'ACTIVE'))

              post :check_coupon, params: { coupon_code: }
              expect(response).to have_http_status(:not_found)
            end
          end

          context 'when the shop does not have a recurring charge' do
            it 'returns valid = true' do
              expect(ShopifyBilling::CouponCode).to receive(:find_by!).with(coupon_code:).and_return(coupon)
              allow(ShopifyAPI::RecurringApplicationCharge).to receive(:current).and_return(nil)
              expect(coupon).to receive(:coupon_valid?).with(shop).and_return(true)

              post :check_coupon, params: { coupon_code: }
              expect(response).to have_http_status(:ok)
              expect(response.parsed_body['valid']).to eq(true)
            end
          end
        end
      end
    end
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
      expect(controller).to receive(:init_shop_settings)
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
