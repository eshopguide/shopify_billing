# frozen_string_literal: true

require 'rails'
require 'bundler'
require 'combustion'
require 'simplecov'
require 'shopify_billing'

SimpleCov.start 'rails' do
  add_filter '/spec/'
  add_filter '/config/'
  add_filter '/vendor/'
end

Bundler.require :default, :development

Combustion.initialize! :active_record, :action_controller, :action_view do
  config.logger = Logger.new(nil)
  config.eager_load = false
end

require 'rspec/rails'

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.use_transactional_fixtures = true
end
