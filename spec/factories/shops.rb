# frozen_string_literal: true

FactoryBot.define do
  factory :shop do
    shopify_domain { "#{SecureRandom.hex(8)}.myshopify.com" }
    shopify_token { "shpat_#{SecureRandom.hex(12)}" }
    email { nil }
    name { nil }
    country { nil }
    shop_owner { nil }
    discount_percent { 0.0 }
    nohelp { nil }
    lexoffice_token { SecureRandom.hex(15) }
    lexoffice_refresh_token { SecureRandom.hex(15) }
    lexoffice_token_expires_at { 1.hour.from_now }
    lexoffice_tax_type { 'net' }
    lexoffice_small_business { false }
    lexoffice_connection_id { SecureRandom.hex(12) }
    connection_established_at { Time.zone.now }
    connection_needs_auth_refresh { false }
    last_error_mail_sent { nil }
    distance_sales_principle { 'not defined' }
    import_discount_percent { 0 }
    finance_scope { [true, false].sample }
    coupon_code_id { nil }
    trial_ends_on { Time.zone.today }
    import_manually_unlocked_at { nil }
    internal_test_shop { false }
    import_unlocked_at { nil }
    access_scopes { '' }
  end
end
