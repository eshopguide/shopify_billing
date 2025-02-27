# frozen_string_literal: true

module ShopifyBilling
  class Charge < ApplicationRecord
    self.table_name = 'charges'
    belongs_to :billing_plan
  end
end
