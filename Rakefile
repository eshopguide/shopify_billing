# frozen_string_literal: true

require 'bundler/setup'
require 'combustion'
require 'rspec/core/rake_task'

# Initialize Combustion
Combustion.initialize! :active_record, :action_controller, :action_view

# Load Rails tasks
require 'rails/tasks'

# Load RSpec tasks
RSpec::Core::RakeTask.new(:spec)

task default: :spec

require 'bundler/gem_tasks'
