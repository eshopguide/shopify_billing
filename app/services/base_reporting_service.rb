# frozen_string_literal: true

module ShopifyBilling
  class BaseReportingService < ApplicationService
    include EventReporter

    protected

    def verification_token
      Digest::SHA1.hexdigest([@shop.id, @billing_plan.id].join('|'))
    end
  end
end