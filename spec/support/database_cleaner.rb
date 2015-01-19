# RSpec
# spec/support/database_cleaner.rb
RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.clean_with :truncation, {:except => %w[categories]}
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:context) do
    DatabaseCleaner.start
  end

  config.after(:context) do
    DatabaseCleaner.clean
  end
end
