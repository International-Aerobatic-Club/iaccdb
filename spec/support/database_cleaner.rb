# RSpec
# spec/support/database_cleaner.rb

def truncate_database
  DatabaseCleaner.clean_with :truncation
  Rails.application.load_seed
end

RSpec.configure do |config|
  config.before(:suite) do
    truncate_database
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  # selenium driver as separate process breaks transaction strategy
  config.before(:each, viz: true) do
    truncate_database
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
