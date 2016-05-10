# RSpec
# spec/support/database_cleaner.rb
RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.clean_with :truncation, { except: %w[ categories ] }
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  # selenium driver as separate process breaks transaction strategy
  config.before(:each, viz: true) do
    DatabaseCleaner.strategy = :truncation, { except: %w[ categories ] }
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
