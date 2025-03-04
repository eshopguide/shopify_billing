# frozen_string_literal: true

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  # This helps locate factories in both the engine and main app
  config.before(:suite) do
    # Engine factories
    engine_factories = File.join(File.dirname(__FILE__), '..', 'factories')

    # Main app factories - adjust the path if needed
    main_app_factories = Rails.root.join('spec/factories')

    FactoryBot.definition_file_paths << engine_factories
    FactoryBot.definition_file_paths << main_app_factories if Dir.exist?(main_app_factories)

    FactoryBot.find_definitions
  end
end
