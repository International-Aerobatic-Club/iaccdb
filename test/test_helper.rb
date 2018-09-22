ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"
require 'minitest/great_expectations'

# Improved Minitest output (color and progress bar)
#require "minitest/reporters"
#Minitest::Reporters.use!(
#  Minitest::Reporters::ProgressReporter.new,
#  ENV,
#  Minitest.backtrace_filter)

# FactoryBot
class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods
end

# Faker Unique
Minitest.after_run do
  Faker::UniqueGenerator.clear
end

# Thoughtbot context in tests
require 'shoulda/context'

# Capybara
require "capybara/rails"
require "capybara/minitest"
require "capybara/webkit"

Capybara.configure do |config|
  config.javascript_driver = :webkit
end

Capybara::Webkit.configure do |config|
  config.block_unknown_urls
end

class ActionDispatch::IntegrationTest
  include Capybara::DSL
  include Capybara::Minitest::Assertions
  include AuthHelper::Request

  def teardown
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end

class ActionController::TestCase
  include AuthHelper::Controller
end
