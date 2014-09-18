# RSpec
# spec/support/factory_girl.rb
RSpec.configure do |config|
  config.before(:suite) do
    FactoryGirl.lint
  end

  config.include FactoryGirl::Syntax::Methods
end
