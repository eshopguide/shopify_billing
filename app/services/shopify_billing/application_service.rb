# frozen_string_literal: true

module ShopifyBilling
  class ApplicationService
    def self.call(**args)
      new(**args).call
    end
  end
end
