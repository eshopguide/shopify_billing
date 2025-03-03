# frozen_string_literal: true

require 'shopify_billing/engine'

module ShopifyBilling
  mattr_accessor :event_reporter_class_name

  self.event_reporter_class_name = 'ShopifyBilling::NullEventReporter'

  def self.setup
    yield self
  end

  def self.event_reporter
    event_reporter_class_name.constantize
  end

  # Default no-op event reporter
  class NullEventReporter
    def self.log_event(*)
      # Do nothing
    end
  end
end
