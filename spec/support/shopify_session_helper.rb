# frozen_string_literal: true

module ShopifySessionHelper

  def with_shopify_session
    yield if block_given?
  end

  def create_shopify_session(shop_domain)
    ShopifyAPI::Auth::Session.new(
      shop: shop_domain,
      access_token: 'test_token',
      scope: 'read_products,write_products'
    )
  end

  def mock_shopify_session(shop)
    session = create_shopify_session(shop.shopify_domain)
    allow(ShopifyBilling::AuthenticatedController).to receive(:current_shopify_session).and_return(session)
    allow(ShopifyAPI::Auth::Session).to receive(:find_by_shop).and_return(session)
  end
end

RSpec.configure do |config|
  config.include ShopifySessionHelper
end
