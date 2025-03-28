# frozen_string_literal: true

module ShopifyBilling
  class AuthenticatedController < ShopifyBilling::ApplicationController
    include ShopifyApp::EnsureHasSession

    def current_shop
      raise NotImplementedError, 'current_shop must be implemented by the host application'
    end
  end
end
