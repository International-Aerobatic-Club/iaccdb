# RSpec
# spec/support/factory_bot.rb
# Note: The DatabaseCleaner configuration is not guaranteed to run after this
RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end
