# frozen_string_literal: true

module ShopifyBilling
  class AuthenticatedController < ShopifyBilling::ApplicationController
    include ShopifyApp::EnsureHasSession
    before_action :handle_access_scopes

    def handle_access_scopes
      NotImplementedError 'handle_access_scopes must be implemented by the host application'
    end
  end
end
