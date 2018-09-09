require 'test_helper'
require_relative 'contest_result_data'

module IAC
  class NorthwestTest < ActiveSupport::TestCase
    include ContestResultData

    test 'two contest competitor qualifies' do
      setup_contest_results(2015, 'NorthWest')
      computer = RegionalSeries.new
      computer.compute_results(year, region)
      assert_equal(2, pilot_smith.pc_results.count)
      rs = RegionalPilot.where(
        pilot: pilot_smith,
        region: region,
        year: year)
      refute_nil(rs)
      assert_equal(1, rs.count)
      rs = rs.first
      refute_nil(rs)
      assert_equal(2, rs.pc_results.count)
      assert_in_delta(70.33, rs.percentage)
      assert(rs.qualified)
      assert_equal(category, rs.category)
    end

    test '2018 two contest competitor does not qualify' do
      setup_contest_results(2018, 'NorthWest')
      computer = RegionalSeries.new
      computer.compute_results(year, region)
      assert_equal(2, pilot_smith.pc_results.count)
      rs = RegionalPilot.where(
        pilot: pilot_smith,
        region: region,
        year: year)
      refute_nil(rs)
      assert_equal(1, rs.count)
      rs = rs.first
      refute_nil(rs)
      assert_equal(2, rs.pc_results.count)
      assert_in_delta(70.33, rs.percentage)
      refute(rs.qualified)
      assert_equal(category, rs.category)
    end
  end
end
