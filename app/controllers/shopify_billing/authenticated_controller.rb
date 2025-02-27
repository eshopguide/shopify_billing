# frozen_string_literal: true

module ShopifyBilling
  class AuthenticatedController < ShopifyBilling::ApplicationController
    include ShopifyApp::EnsureHasSession

    private

    def set_current_shop
      return unless current_shopify_session

      @current_shop = Shop.find_by(shopify_domain: current_shopify_session.shop)
    end
  end
end
