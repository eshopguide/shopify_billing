# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Specify your gem's dependencies in shopify_billing.gemspec.
gemspec

gem 'puma'

group :development, :test do
  gem 'combustion', '~> 1.5.0'
  gem 'database_cleaner-active_record', '~> 2.2.0'
  gem 'dotenv-rails', '~> 2.8.1'
  gem 'factory_bot_rails', '~> 6.4.4'
  gem 'faker', '~> 3.2.2'
  gem 'pg', '~> 1.5.8'
  gem 'rspec-rails', '~> 7.1.1'
  gem 'rubocop', '~> 1.50'
  gem 'rubocop-rails', '~> 2.19'
  gem 'rubocop-rspec', '~> 2.22'
  gem 'shoulda-matchers', '~> 5.3.0'
  gem 'simplecov', '~> 0.21.2'
end

gem 'central_event_logger', '0.1.7', github: 'eshopguide/centralized-logging'
gem 'sprockets-rails'
gem 'sqlite3'
gem "shopify_graphql", "~> 2.0"

# Start debugger with binding.b [https://github.com/ruby/debug]
# gem "debug", ">= 1.0.0"
