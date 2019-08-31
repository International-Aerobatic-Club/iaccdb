require_relative '../../test/auth_for_test'

RSpec.configure do |config|
  config.include AuthForTest::Controller, :type => :controller
  config.include AuthForTest::Request, :type => :request
  config.include AuthForTest::Feature, :type => :feature
end
