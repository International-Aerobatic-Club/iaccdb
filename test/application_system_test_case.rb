require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include AuthHelper::Feature
  driven_by :selenium, using: :firefox, screen_size: [1400, 1400]
end
