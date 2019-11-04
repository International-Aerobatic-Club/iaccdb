require 'test_helper'
require 'shared/basic_contest_data'

class ContestsControllerNoAirplaneTest < ActionDispatch::IntegrationTest
  include BasicContestData

  setup do
    setup_basic_contest_data
    cc = ContestComputer.new(@contest)
    cc.compute_results
  end

  test "contest with no airplanes" do
    Airplane.destroy_all
    get contest_path(@contest, format: :json)
    assert_response :success
  end
end
