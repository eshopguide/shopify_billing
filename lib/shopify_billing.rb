# frozen_string_literal: true

require 'shopify_billing/engine'
require 'shopify_billing/version'

module ShopifyBilling
  mattr_accessor :event_reporter
  mattr_accessor :shop_class

  def self.setup
    yield self
  end
end
