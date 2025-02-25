# frozen_string_literal: true

module ShopifyBilling
  class ApplicationService
    include EventReporter

    def self.call(*args, **kwargs)
      new(*args, **kwargs).call
    end
  end
end
