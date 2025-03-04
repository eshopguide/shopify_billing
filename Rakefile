# frozen_string_literal: true

require 'bundler/setup'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

# Create the environment task that Rails would normally provide
task environment: :environment do
  require 'combustion'

  # Set Rails environment to test if not already set
  ENV['RAILS_ENV'] ||= 'test'

  # Initialize Combustion with minimal Rails components
  Combustion.initialize! :active_record do
    config.logger = Logger.new($stdout)
    config.log_level = :info
  end

  puts "Rails environment loaded: #{Rails.env}"
end

# Load custom tasks
Dir.glob('lib/tasks/**/*.rake').each { |r| load r }

RSpec::Core::RakeTask.new(:spec)

task default: :spec
