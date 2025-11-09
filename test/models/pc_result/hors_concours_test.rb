require 'test_helper'
require 'shared/hors_concours_data'

class PcResult::HorsConcoursTest < ActiveSupport::TestCase
  include HorsConcoursData

  setup do
    setup_hors_concours_data
  end

  test 'carries hors_concours on pilot_flight into pf_results' do
    pf_results = PfResult.joins(flight: :contest).where(
      ['flights.contest_id = ? and pilot_flights.pilot_id = ?', 
        @contest.id, @hc_pilot.id])
    assert_equal(2, pf_results.count)
    pf_results.each do |pf|
      assert(pf.hors_concours?)
    end
  end

  test 'carries hors_concours on any pilot_flight into pc_results' do
    pc_results = PcResult.where(contest: @contest, pilot: @hc_pilot)
    assert_equal(1, pc_results.count)
    assert(pc_results.first.hors_concours?)
  end

  test 'does not set hc if none of the flights is hc' do
    pc_results = PcResult.where(contest: @contest, pilot: @non_hc_pilot)
    assert_equal(1, pc_results.count)
    refute(pc_results.first.hors_concours?)
  end
end
