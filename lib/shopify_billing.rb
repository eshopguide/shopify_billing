# frozen_string_literal: true

require 'shopify_billing/engine'

module ShopifyBilling
  mattr_accessor :event_reporter
  mattr_accessor :shop_class

  def self.setup
    yield self
  end

  def self.report_event?
    event_reporter.present?
  end
end
