# frozen_string_literal: true

require 'shopify_billing/version'
require 'shopify_billing/engine'

module ShopifyBilling
  mattr_accessor :event_reporter_class_name
  mattr_accessor :base_controller
  mattr_accessor :authenticated_controller

  self.event_reporter_class_name = 'ShopifyBilling::NullEventReporter'
  self.base_controller = 'ShopifyBilling::ApplicationController'
  self.authenticated_controller = 'ShopifyBilling::AuthenticatedController'

  def self.setup
    yield self
  end

  def self.event_reporter
    event_reporter_class_name.constantize
  end

  def self.base_controller_class
    base_controller.constantize
  end

  def self.authenticated_controller_class
    authenticated_controller.constantize
  end

  # Default no-op event reporter
  class NullEventReporter
    def self.log_event(*)
      # Do nothing
    end
  end
end
