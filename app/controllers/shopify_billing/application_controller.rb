# frozen_string_literal: true

module ShopifyBilling
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :null_session
    before_action :handle_locale

    def shopify_host
      raise NotImplementedError, 'shopify_host must be implemented by the host application'
    end

    def redirect_to_admin(path = nil, status = nil)
      raise NotImplementedError, 'redirect_to_admin must be implemented by the host application'
    end

    def handle_locale
      raise NotImplementedError, 'handle_locale must be implemented by the host application'
    end

    def init_shop_settings
      raise NotImplementedError, 'init_shop_settings must be implemented by the host application'
    end
  end
end
