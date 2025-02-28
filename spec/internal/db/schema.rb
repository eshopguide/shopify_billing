# frozen_string_literal: true

ActiveRecord::Schema[7.0].define(version: 2025_02_17_111013) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql" if ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'

  create_table "shops", force: true do |t|
    t.string "shopify_domain", null: false
    t.string "shopify_token", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "email"
    t.string "name"
    t.string "country"
    t.string "shop_owner"
    t.integer "legacy_billing_plan_id", default: 0
    t.decimal "discount_percent", default: "0.0"
    t.boolean "legacy_billing_activated", default: false
    t.boolean "legacy_plan_needs_update", default: false
    t.boolean "nohelp"
    t.boolean "legacy_import_unlocked"
    t.integer "service_instance_id", default: 1
    t.string "lexoffice_token"
    t.string "lexoffice_refresh_token"
    t.integer "lexoffice_token_expires_at"
    t.boolean "credit_note_scope"
    t.boolean "send_mail_scope"
    t.string "lexoffice_organization_id"
    t.string "lexoffice_tax_type"
    t.boolean "lexoffice_small_business"
    t.string "lexoffice_connection_id"
    t.datetime "connection_established_at", precision: nil
    t.boolean "connection_needs_auth_refresh"
    t.datetime "last_error_mail_sent", precision: nil
    t.string "distance_sales_principle", default: "not defined"
    t.integer "import_discount_percent", default: 0
    t.boolean "finance_scope"
    t.integer "finance_account_id"
    t.integer "coupon_code_id"
    t.bigint "redeemed_coupon_id"
    t.date "trial_ends_on"
    t.boolean "invoice_info_job_ran", default: false
    t.datetime "plan_mismatch_since"
    t.boolean "has_multiple_tax_lines"
    t.string "access_scopes", default: "", null: false
    t.boolean "tmp_has_missing_recurring_charge", default: false, null: false
    t.datetime "import_manually_unlocked_at"
    t.boolean "internal_test_shop", default: false, null: false
    t.datetime "import_unlocked_at"
    t.index ["legacy_billing_plan_id"], name: "index_shops_on_legacy_billing_plan_id"
    t.index ["lexoffice_organization_id"], name: "index_shops_on_lexoffice_organization_id"
    t.index ["service_instance_id"], name: "index_shops_on_service_instance_id"
  end

  create_table "billing_plans", force: :cascade do |t|
    t.string "name"
    t.string "short_name"
    t.decimal "price"
    t.integer "warning"
    t.integer "threshold"
    t.boolean "default"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "matches_shopify_plan"
    t.string "plan_type"
    t.text "features", default: [], array: true
    t.boolean "recommended", default: false
    t.boolean "development_plan", default: false
    t.boolean "available_for_development_shop", default: false
    t.boolean "available_for_production_shop", default: true
    t.index ["short_name"], name: "index_billing_plans_on_short_name"
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
