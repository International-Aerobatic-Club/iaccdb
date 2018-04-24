RSpec.configure do |config|
  config.include AuthHelper::Controller, :type => :controller
  config.include AuthHelper::Request, :type => :request
  config.include AuthHelper::Feature, :type => :feature
end

