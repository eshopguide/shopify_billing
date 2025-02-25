# frozen_string_literal: true

module ShopifyBilling
  class Charge < ApplicationRecord
    belongs_to :billing_plan
  end
end
