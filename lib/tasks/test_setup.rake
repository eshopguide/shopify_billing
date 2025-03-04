# frozen_string_literal: true

namespace :test do
  desc 'Setup test database for Combustion'
  task setup: [] do  # Remove the dependency on :environment
    require 'bundler/setup'
    require 'combustion'

    # Set Rails environment to test
    ENV['RAILS_ENV'] = 'test'

    # Initialize Combustion
    Combustion.initialize! :active_record

    # Create the database
    ActiveRecord::Tasks::DatabaseTasks.create_current

    # Load the schema
    ActiveRecord::Tasks::DatabaseTasks.load_schema_current

    puts 'Test database setup completed successfully'
  end
end
