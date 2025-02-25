# frozen_string_literal: true

module ShopifyBilling
  class Engine < ::Rails::Engine
    isolate_namespace ShopifyBilling

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
      g.factory_bot dir: 'spec/factories'
    end

    # Configure event reporting
    config.event_reporter = nil

    initializer 'shopify_billing.event_reporter' do |app|
      ShopifyBilling.event_reporter = app.config.event_reporter
    end

       # Disable factory loading temporarily
    # initializer 'shopify_billing.factories', after: 'factory_bot.set_factory_paths' do
    #   if defined?(FactoryBot)
    #     FactoryBot.definition_file_paths << File.expand_path('../../spec/factories', __dir__)
    #     FactoryBot.reload
    #   end
    # end
  end
end