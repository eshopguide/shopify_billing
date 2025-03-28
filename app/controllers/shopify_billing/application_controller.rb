# frozen_string_literal: true

module ShopifyBilling
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :null_session

    def shopify_host
      raise NotImplementedError, 'shopify_host must be implemented by the host application'
    end

    def redirect_to_admin(path = nil, status = nil)
      raise NotImplementedError, 'redirect_to_admin must be implemented by the host application'
    end
  end
end
