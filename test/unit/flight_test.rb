require 'test_helper'

class FlightTest < ActiveSupport::TestCase
  test "count judges" do
    assert_equal(2, flights(:one).count_judges) 
  end
end
