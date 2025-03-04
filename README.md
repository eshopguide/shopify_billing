# ShopifyBilling

[![Ruby Tests and Linting](https://github.com/eshopguide/shopify_billing/actions/workflows/rspec.yml/badge.svg)](https://github.com/eshopguide/shopify_billing/actions/workflows/rspec.yml)

A Ruby on Rails engine for handling Shopify billing and subscription management in Shopify applications.

## Overview

ShopifyBilling provides a complete solution for managing Shopify app billing, including:

- Recurring application charges (subscriptions)
- One-time application charges
- Trial periods
- Coupon code management
- Billing plan management
- Charge creation and verification

This gem is designed to work with the Shopify API and integrates with the `shopify_app` gem to provide a seamless billing experience for your Shopify app users.

## Usage
How to use my plugin.

## Installation
Add this line to your application's Gemfile:

```ruby
gem "shopify_billing"
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install shopify_billing
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.

You can also run `bin/console` for an interactive prompt that will allow you to experiment with the gem.

### Releasing a new version

To release a new version:

1. Update the version number in `lib/shopify_billing/version.rb`
2. Commit your changes
3. Create a new tag with the version: `git tag v0.1.1`
4. Push the tag: `git push origin v0.1.1`

The GitHub Actions workflow will automatically create a new release and build the gem.
