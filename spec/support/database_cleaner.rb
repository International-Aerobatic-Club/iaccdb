# RSpec
# spec/support/database_cleaner.rb

def truncate_database
  DatabaseCleaner.clean_with :truncation
  Rails.application.load_seed
end

def start_transaction
  DatabaseCleaner.strategy = :transaction
  DatabaseCleaner.start
end

def end_transaction
  DatabaseCleaner.clean
end

RSpec.configure do |config|
  config.before(:suite) do
    truncate_database
  end

  # selenium driver as separate process breaks transaction strategy
  config.before(:example, viz: true) do
    truncate_database
  end

  config.before(:context) do
    start_transaction
  end

  config.after(:context) do
    end_transaction
  end

  config.before(:example) do
    start_transaction
  end

  config.after(:example) do
    end_transaction
  end
end
