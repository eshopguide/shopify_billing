# frozen_string_literal: true

module ShopifyBilling
  class BaseReportingService < ShopifyBilling::ApplicationService
    protected

    def verification_token
      Digest::SHA1.hexdigest([@shop.id, @billing_plan.id].join('|'))
    end
    
    def report_event(event_data)
      # Stub implementation for tests
    end
  end
end