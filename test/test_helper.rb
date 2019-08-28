ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"
require 'minitest/great_expectations'
require 'shoulda/context' # Thoughtbot context in tests

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

class ActionController::TestCase
  include AuthHelper::Controller
end
