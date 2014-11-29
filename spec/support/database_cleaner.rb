# RSpec
# spec/support/database_cleaner.rb
RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation, {:except => %w[categories]}
    DatabaseCleaner.clean
  end

  config.around(:example) do |test|
    DatabaseCleaner.cleaning do
      test.run
    end
  end
end
