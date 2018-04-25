RSpec.configure do |config|
  config.after :example do
    Faker::UniqueGenerator.clear
  end
end
