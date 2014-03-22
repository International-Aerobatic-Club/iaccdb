ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    clean_db
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.mock_with :rspec
end

def clean_db
  DatabaseCleaner.clean_with :truncation
  load "#{Rails.root}/db/seeds.rb"
end

def reset_db
  DatabaseCleaner.clean
  DatabaseCleaner.start
end
