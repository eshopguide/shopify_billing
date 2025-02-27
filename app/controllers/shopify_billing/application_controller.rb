# frozen_string_literal: true

module ShopifyBilling
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :null_session
    before_action :handle_locale

    private

    def handle_locale
      locale = params[:locale] || request.headers[:locale]
      return if locale.blank?

      locale = locale[0..1]
      begin
        I18n.locale = locale
        session[:locale] = locale
      rescue I18n::InvalidLocale
        I18n.locale = I18n.default_locale
        session[:locale] = I18n.default_locale
      end
    end

    def shopify_host
      request.headers['x-host'] || params[:host] || session[:host]
    end

    def redirect_to_admin(path = nil, status = nil)
      frontend_url = ShopifyAPI::Auth.embedded_app_url(shopify_host)
      frontend_url += "/#{path}" if path.present?
      frontend_url += "?status=#{status}" if status.present?
      redirect_to(frontend_url, allow_other_host: true)
    end
  end
end
