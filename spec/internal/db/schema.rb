# frozen_string_literal: true

ActiveRecord::Schema[7.0].define(version: 2025_02_17_111013) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql" if ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'

  create_table "shops", force: true do |t|
    t.string "shopify_domain", null: false
    t.string "shopify_token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "development_shop", default: false
    t.boolean "internal_test_shop", default: false
    t.integer "billing_plan_id"
    t.date "trial_ends_on"
    t.integer "discount_percent", default: 0
    t.integer "import_discount_percent", default: 0
    t.boolean "import_unlocked", default: false
    t.datetime "plan_mismatch_since"
    t.boolean "tmp_has_missing_recurring_charge", default: false
    t.bigint "redeemed_coupon_id"
    t.string "email"
    t.string "name"
    t.string "country"
    t.string "shop_owner"
  end

  create_table "billing_plans", force: true do |t|
    t.string "name", null: false
    t.string "short_name", null: false
    t.decimal "price", precision: 8, scale: 2, null: false
    t.string "plan_type", default: 'recurring'
    t.boolean "development_plan", default: false
    t.boolean "recommended", default: false
    t.boolean "available_for_development_shop", default: true
    t.boolean "available_for_production_shop", default: true
    t.timestamps
  end

  create_table "charges", force: true do |t|
    t.string "shopify_id", null: false
    t.references "billing_plan"
    t.timestamps
  end

  create_table "coupon_codes", force: true do |t|
    t.string "type"
    t.string "coupon_code", null: false
    t.boolean "redeemed", default: false
    t.integer "shop_id"
    t.integer "redeem_counter", default: 1
    t.date "validity"
    t.integer "free_days", default: 0
    t.timestamps
  end
end
