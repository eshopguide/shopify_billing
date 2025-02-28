source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Specify your gem's dependencies in shopify_billing.gemspec.
gemspec

gem "puma"

group :development, :test do
  gem 'pg', '~> 1.5.8'
end

gem "sqlite3"

gem "sprockets-rails"

gem 'central_event_logger', '0.1.7', github: 'eshopguide/centralized-logging'

# Start debugger with binding.b [https://github.com/ruby/debug]
# gem "debug", ">= 1.0.0"
