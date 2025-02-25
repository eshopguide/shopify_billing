# frozen_string_literal: true

class ShopifyBilling::ApplicationController < ActionController::Base
    before_action :handle_locale
    # include ShopifyApp::LoginProtection
    # Prevent CSRF attacks by raising an exception.
    # For APIs, you may want to use :null_session instead.
    protect_from_forgery with: :null_session
  
    def init_shop_settings
      @current_shop = Shop.find_or_create_new(current_shopify_session)
      @current_shop.update_shop_info
      @shop_settings = @current_shop.shop_setting
    end
  
    def shopify_host
      request.headers['x-host'] || params[:host] || session[:host]
    end
  
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
  
    private
  
    def redirect_to_admin(path = nil, status = nil)
      frontend_url = ShopifyAPI::Auth.embedded_app_url(shopify_host)
      frontend_url += "/#{path}" if path.present?
      frontend_url += "?status=#{status}" if status.present?
      redirect_to(frontend_url, allow_other_host: true)
    end
  end