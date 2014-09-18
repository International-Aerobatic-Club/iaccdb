# RSpec
# spec/support/database_cleaner.rb
RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation, { :except => %w[cat_classes qualities sim_types price_plans] }
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |test|
    DatabaseCleaner.cleaning do
      test.run
    end
  end
end
