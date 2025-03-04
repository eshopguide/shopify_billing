# frozen_string_literal: true

namespace :test do
  desc 'Setup test database for Combustion'
  task setup: :environment do
    # Create the database
    ActiveRecord::Tasks::DatabaseTasks.create_current

    # Load the schema
    ActiveRecord::Tasks::DatabaseTasks.load_schema_current

    puts 'Test database setup completed successfully'
  end
end
