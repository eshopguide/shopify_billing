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

## Database Requirements

ShopifyBilling is designed to work with your existing database rather than creating its own separate tables. The gem requires the following tables to be present in your application's database:

### Required Tables

#### billing_plans
```ruby
create_table "billing_plans", force: :cascade do |t|
  t.string "name"
  t.string "short_name"
  t.decimal "price"
  t.integer "warning"
  t.integer "threshold"
  t.boolean "default"
  t.datetime "created_at", precision: nil, null: false
  t.datetime "updated_at", precision: nil, null: false
  t.string "matches_shopify_plan"
  t.string "plan_type"
  t.text "features", default: [], array: true
  t.boolean "recommended", default: false
  t.boolean "development_plan", default: false
  t.boolean "available_for_development_shop", default: false
  t.boolean "available_for_production_shop", default: true
  t.index ["short_name"], name: "index_billing_plans_on_short_name"
end
```

#### charges
```ruby
create_table "charges", force: true do |t|
  t.string "shopify_id", null: false
  t.references "billing_plan"
  t.timestamps
end
```

#### coupon_codes
```ruby
create_table "coupon_codes", force: true do |t|
  t.string "type"
  t.string "coupon_code", null: false
  t.boolean "redeemed", default: false
  t.integer "shop_id"
  t.integer "redeem_counter", default: 1
  t.date "validity"
  t.integer "free_days", default: 0
  t.timestamps
end
```

### Database Setup

If you're integrating this gem into an existing application, ensure your database already has the required tables. If not, you'll need to create migrations for these tables.

Example migration for creating the required tables:

```ruby
class CreateShopifyBillingTables < ActiveRecord::Migration[7.0]
  def change
    create_table "billing_plans", force: :cascade do |t|
      t.string "name"
      t.string "short_name"
      t.decimal "price"
      t.integer "warning"
      t.integer "threshold"
      t.boolean "default"
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.string "matches_shopify_plan"
      t.string "plan_type"
      t.text "features", default: [], array: true
      t.boolean "recommended", default: false
      t.boolean "development_plan", default: false
      t.boolean "available_for_development_shop", default: false
      t.boolean "available_for_production_shop", default: true
      t.string "interval"
      t.index ["short_name"], name: "index_billing_plans_on_short_name"
    end

    create_table "charges", force: true do |t|
      t.string "shopify_id", null: false
      t.references "billing_plan"
      t.timestamps
    end

    create_table "coupon_codes", force: true do |t|
      t.string "type"
      t.string "coupon_code", null: false
      t.boolean "redeemed", default: false
      t.integer "shop_id"
      t.integer "redeem_counter", default: 1
      t.date "validity"
      t.integer "free_days", default: 0
      t.timestamps
    end
  end
end
```

## Configuration

### Environment Variables

The gem requires the following environment variables:

- `APP_NAME` - The name of your Shopify app
- `TRIAL_DAYS` - Number of trial days for recurring plans (default: 14)
- `HOST_NAME` - Your app's hostname
- `TEST_CHARGE` - Set to "true" to create test charges (for development)

### Routes

Mount the engine in your `routes.rb` file:

```ruby
Rails.application.routes.draw do
  mount ShopifyBilling::Engine, at: '/shopify_billing'
  
  # Your other routes...
end
```

This will make the following routes available:

- `POST /shopify_billing/billing/charge` - Create a new charge
- `GET /shopify_billing/billing/plans` - Get available billing plans
- `POST /shopify_billing/billing/check_coupon` - Check if a coupon code is valid
- `GET /shopify_billing/handle_charge` - Handle charge callback from Shopify

### Controller Configuration

The gem allows you to configure the base controllers used for billing functionality. You can do this in your application's initializer:

```ruby
# config/initializers/shopify_billing.rb
ShopifyBilling.setup do |config|
  # Configure the base controller for non-authenticated endpoints
  config.base_controller = 'YourApp::BaseController'
  
  # Configure the controller for authenticated endpoints
  config.authenticated_controller = 'YourApp::AuthenticatedController'
  
  # Configure the event reporter (optional)
  config.event_reporter_class_name = 'YourApp::EventReporter'
end
```

Your custom controllers must implement the following methods:

```ruby
# In your base controller
def shopify_host
  # Return your app's hostname
end

def redirect_to_admin(path = nil, status = nil)
  # Handle redirection to admin
end
```

If you don't configure custom controllers, the gem will use its default implementations which will raise `NotImplementedError` if the required methods are not implemented.

## Usage

### Billing Plans

Billing plans represent the different subscription options available to your users.

```ruby
# Creating a billing plan
ShopifyBilling::BillingPlan.create!(
  name: 'Basic Plan',
  short_name: 'basic',
  price: 19.99,
  plan_type: 'recurring',
  interval: 'ANNUAL' # Possible options: ANNUAL or EVERY_30_DAYS
  features: ['feature1', 'feature2'],
  recommended: true,
  available_for_development_shop: true,
  available_for_production_shop: true
)

```

### Creating Charges

To create a new charge for a shop:

```ruby
charge = ShopifyBilling::CreateChargeService.call(
  shop: current_shop,
  billing_plan_id: plan.id,
  host: request.host,
  coupon_code: params[:coupon_code]
)

if charge&.confirmation_url
  redirect_to charge.confirmation_url
else
  # Handle error
end
```

### Getting Available Plans

To get the available billing plans for a shop:

```ruby
plans = ShopifyBilling::SelectAvailableBillingPlansService.call(
  shop: current_shop,
  coupon_code: params[:coupon_code]
)
```

### Checking Coupon Codes

To check if a coupon code is valid:

```ruby
begin
  coupon = ShopifyBilling::CouponCode.find_by!(coupon_code: params[:coupon_code])
  
  if coupon.coupon_valid?(current_shop)
    # Coupon is valid
  else
    # Coupon is invalid
  end
rescue ActiveRecord::RecordNotFound
  # Coupon not found
end
```

### Handling Charge Callbacks

The gem automatically handles charge callbacks from Shopify. When a user accepts or declines a charge, Shopify will redirect them to the callback URL, which will be processed by the `HandleChargeService`.

## Models

### BillingPlan

Represents a billing plan with pricing and features.

Key methods:
- `recurring?` - Returns true if the plan is recurring
- `one_time?` - Returns true if the plan is one-time
- `apply_coupon(coupon)` - Apply a coupon to the plan
- `trial_days_for_shop(shop)` - Get trial days for a shop
- `price_for_shop(shop)` - Get the price for a shop (including discounts)

### Charge

Represents a Shopify charge (either one-time or recurring).

### CouponCode

Base class for coupon codes.

## Services

### CreateChargeService

Creates a new charge for a shop.

### HandleChargeService

Handles the callback from Shopify after a charge is accepted or declined.

### SelectAvailableBillingPlansService

Returns available billing plans for a shop.

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

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
