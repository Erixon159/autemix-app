# Database Cleaner configuration
require 'database_cleaner/active_record'

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  rescue DatabaseCleaner::Safeguard::Error::RemoteDatabaseUrl
    # Allow database cleaner to work with remote database URLs in test environment
    DatabaseCleaner.allow_remote_database_url = true
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
