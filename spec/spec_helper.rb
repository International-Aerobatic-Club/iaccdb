ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:all) do
    DatabaseCleaner.start
  end

  config.after(:all) do
    DatabaseCleaner.clean
  end

  config.mock_with :rspec
  config.use_transactional_fixtures = false
end

def reset_db
  DatabaseCleaner.clean
  DatabaseCleaner.start
end
