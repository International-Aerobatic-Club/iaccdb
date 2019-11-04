require 'test_helper'

class PilotControllerTest < ActionDispatch::IntegrationTest
  setup do
    @pilot = create(:member)
    pfs = create_list(:pilot_flight, 4, pilot: @pilot)
  end

  test "should get show" do
    get pilot_path(@pilot)
    assert_response :success
  end

end
