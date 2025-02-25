module ShopifyBilling
  class Charge < ApplicationRecord
    belongs_to :billing_plan
  end
end
