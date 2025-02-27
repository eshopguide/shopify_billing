ENV['APP_NAME'] ||= 'ShopifyBilling'
ENV['TRIAL_DAYS'] ||= '14'
# Add any other environment variables your tests need

Rails.application.configure do
  config.eager_load = false
  config.active_support.deprecation = :stderr
  config.active_support.test_order = :random
  config.action_controller.allow_forgery_protection = false
  config.action_mailer.delivery_method = :test
  config.active_job.queue_adapter = :test
  config.log_level = :info
end