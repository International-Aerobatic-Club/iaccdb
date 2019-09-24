require 'test_helper'
require 'shared/basic_contest_data'

class ScoresController::ShowTest < ActionController::TestCase
  include BasicContestData

  setup do
    setup_basic_contest_data
    cc = ContestComputer.new(@contest)
    cc.compute_results
  end

  test 'shows contest flights with scores for one pilot' do
    pilot = @pilots.first
    get :show, params: { pilot_id: pilot.id, id: @contest.id }
    assert_response :success
  end

  test 'contains all of the flights' do
    pilot = @pilots.first
    get :show, params: { pilot_id: pilot.id, id: @contest.id }
    @flights.each do |flight|
      assert_select(
        "div.flightScores h3 a[href='#{flight_path(flight.id)}']")
      assert_select('div.flightScores h3 a', flight.displayName)
    end
  end
end
