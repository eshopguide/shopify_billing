require_relative "lib/shopify_billing/version"

Gem::Specification.new do |spec|
  spec.name        = "shopify_billing"
  spec.version     = ShopifyBilling::VERSION
  spec.authors     = ["Matthew Cwalina"]
  spec.email       = ["matthew@eshop-guide.de"]
  spec.homepage    = "https://eshop-guide.de"
  spec.summary     = "An Engine for handling Shopify Billing"
  spec.description = "Handles billing logic across Shopify Apps"
  spec.license     = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/eshopguide/shopify_billing"
  spec.metadata["changelog_uri"] = "https://github.com/eshopguide/shopify_billing/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", "~> 7.0"
  spec.add_dependency "shopify_api", "~> 14.4"
  spec.add_dependency "shopify_app", ">= 22.3"
  spec.add_dependency "honeybadger", ">= 4.0"

  spec.add_development_dependency "pg", "~> 1.5.8"
  spec.add_development_dependency "combustion", "~> 1.5.0"
  spec.add_development_dependency "rspec-rails", "~> 7.1.1"
  spec.add_development_dependency "factory_bot_rails", "~> 6.4.4"
  spec.add_development_dependency "database_cleaner-active_record", "~> 2.2.0"
  spec.add_development_dependency "shoulda-matchers", "~> 5.3.0"
  spec.add_development_dependency "dotenv-rails", "~> 2.8.1"
  spec.add_development_dependency 'central_event_logger', '0.1.7'
end
