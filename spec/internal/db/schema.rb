# frozen_string_literal: true

ActiveRecord::Schema.define do
  create_table :shops, force: true do |t|
    t.string :shopify_domain, null: false
    t.string :shopify_token, null: false
    t.datetime :created_at, null: false
    t.datetime :updated_at, null: false
    t.boolean :development_shop, default: false
    t.boolean :internal_test_shop, default: false
    t.integer :billing_plan_id
    t.date :trial_ends_on
    t.integer :discount_percent, default: 0
    t.integer :import_discount_percent, default: 0
    t.boolean :import_unlocked, default: false
    t.datetime :plan_mismatch_since
    t.boolean :tmp_has_missing_recurring_charge, default: false
    t.integer :redeemed_coupon_id
  end

  create_table :billing_plans, force: true do |t|
    t.string :name, null: false
    t.string :short_name, null: false
    t.decimal :price, precision: 8, scale: 2, null: false
    t.string :plan_type, default: 'recurring'
    t.boolean :development_plan, default: false
    t.boolean :recommended, default: false
    t.boolean :available_for_development_shop, default: true
    t.boolean :available_for_production_shop, default: true
    t.timestamps
  end

  create_table :charges, force: true do |t|
    t.string :shopify_id
    t.references :billing_plan
    t.timestamps
  end

  create_table :coupon_codes, force: true do |t|
    t.string :type
    t.string :coupon_code, null: false
    t.integer :redeem_counter, default: 0
    t.date :validity
    t.integer :free_days, default: 0
    t.timestamps
  end
end
