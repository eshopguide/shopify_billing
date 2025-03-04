# frozen_string_literal: true

require 'shopify_billing/central_event_logger_adapter'

module ShopifyBilling
  class Engine < ::Rails::Engine
    isolate_namespace ShopifyBilling

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
      g.factory_bot dir: 'spec/factories'
    end

    initializer 'shopify_billing.check_central_event_logger' do
      require 'central_event_logger'
    rescue LoadError
      # CentralEventLogger is not available, we'll use the null reporter
    end
  end
end
