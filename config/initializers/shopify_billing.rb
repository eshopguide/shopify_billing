# frozen_string_literal: true

# Ensure our BillingPlan class is loaded before the gem's version
require_dependency Rails.root.join('app/models/billing_plan').to_s 