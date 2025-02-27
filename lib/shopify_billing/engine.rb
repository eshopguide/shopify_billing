# frozen_string_literal: true

module ShopifyBilling
  class Engine < ::Rails::Engine
    isolate_namespace ShopifyBilling

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
      g.factory_bot dir: 'spec/factories'
    end

    initializer 'shopify_billing.event_reporter' do |app|
      if app.config.respond_to?(:event_reporter) && app.config.event_reporter.present?
        ShopifyBilling.event_reporter = app.config.event_reporter
      end
    end

    initializer 'shopify_billing.honeybadger' do |app|
      if defined?(Honeybadger) && app.config.respond_to?(:honeybadger)
        Honeybadger.configure do |config|
          config.api_key = app.config.honeybadger.api_key if app.config.honeybadger.respond_to?(:api_key)
          config.env = app.config.honeybadger.env if app.config.honeybadger.respond_to?(:env)
        end
      end
    end
  end
end