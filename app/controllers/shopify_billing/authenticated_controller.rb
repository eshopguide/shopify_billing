# frozen_string_literal: true

class ShopifyBilling::AuthenticatedController < ShopifyBilling::ApplicationController
    include ShopifyApp::EnsureHasSession
end