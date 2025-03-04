# frozen_string_literal: true

require 'dotenv'
Dotenv.load('.env.test')

require 'spec_helper'

ENV['RAILS_ENV'] ||= 'test'

require 'rspec/rails'
require 'factory_bot_rails'
require 'database_cleaner/active_record'
require 'shoulda/matchers'

Dir[ShopifyBilling::Engine.root.join('spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.profile_examples = 10

  config.order = :random
  Kernel.srand config.seed
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
