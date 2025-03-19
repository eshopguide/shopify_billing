# frozen_string_literal: true

class Shop < ActiveRecord::Base
  include ShopifyBilling::ShopBilling
  # Used to help with shop sessions and shopify API calls
  include ShopifySessionHelper
  belongs_to :billing_plan, class_name: 'ShopifyBilling::BillingPlan', optional: true
end