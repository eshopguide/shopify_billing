require_relative "lib/shopify_billing/version"

Gem::Specification.new do |spec|
  spec.name        = "shopify_billing"
  spec.version     = ShopifyBilling::VERSION
  spec.authors     = ["Matthew Cwalina"]
  spec.email       = ["matthew@eshop-guide.de"]
  spec.homepage    = "TODO"
  spec.summary     = "An Engine for handling Shopify Billing"
  spec.description = "Handles billing logic across Shopify Apps"
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.0.8.4"
end
