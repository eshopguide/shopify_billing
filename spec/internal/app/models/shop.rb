# frozen_string_literal: true

class Shop < ActiveRecord::Base
  include ShopifyBilling::ShopBilling
  belongs_to :billing_plan, class_name: 'ShopifyBilling::BillingPlan', optional: true

  def with_shopify_session
    yield if block_given?
  end
end