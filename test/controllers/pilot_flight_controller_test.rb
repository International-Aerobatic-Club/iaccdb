require 'test_helper'

class PilotFlightControllerTest < ActionDispatch::IntegrationTest
  setup do
    @pf = create(:pilot_flight)
    judge = create(:judge, assist: nil)
    score = create(:score, pilot_flight: @pf, judge: judge)
  end

  test "should get show json" do
    get pilot_flight_path(@pf, format: :json)
    assert_response :success
  end
end
