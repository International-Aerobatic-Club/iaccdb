# RSpec
# spec/support/factory_girl.rb
# DatabaseCleaner configuration not guaranteed to run after
RSpec.configure do |config|
  #config.after(:suite) do
    # Do it after, because doing it before pollutes the DB
    #FactoryGirl.lint
  #end
  config.include FactoryGirl::Syntax::Methods
end
