# frozen_string_literal: true

class Shop < ActiveRecord::Base
  belongs_to :billing_plan, class_name: 'ShopifyBilling::BillingPlan', optional: true
  
  def development_shop?
    development_shop
  end
  
  def remaining_trial_days
    return 0 unless trial_ends_on
    
    (trial_ends_on - Date.today).to_i
  end
  
  # Add methods needed by the service
  def tmp_has_missing_recurring_charge
    false
  end
  
  def import_unlocked
    false
  end
  
  def reset_app_installation_cache
    # Mock implementation for tests
  end
  
  def with_shopify_session
    yield if block_given?
  end
  
  def internal_test_shop?
    false
  end
  
  def shopify_domain
    "test-shop.myshopify.com"
  end
  
  def name
    "Test Shop"
  end
  
  def shop_owner
    "Test Owner"
  end
  
  def email
    "test@example.com"
  end
end 