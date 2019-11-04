require 'test_helper'

class FlightControllerTest < ActionDispatch::IntegrationTest
  setup do
    @flight = create(:flight)
    pfs = create_list(:pilot_flight, 4, airplane: nil, flight: @flight)
    pfs.each do |pf|
      create_list(:pf_result, 4, pilot_flight: pf)
    end
  end

  test "should get show" do
    get flight_path(@flight, format: :json)
    assert_response :success
  end
end
