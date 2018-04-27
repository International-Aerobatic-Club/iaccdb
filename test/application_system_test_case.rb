require "test_helper"
require 'capybara/poltergeist'

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include AuthHelper::Feature
  driven_by :poltergeist, screen_size: [1400, 1400]
end
