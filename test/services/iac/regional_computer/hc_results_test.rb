require 'test_helper'
require_relative 'contest_result_data'

module IAC
  class HcResultsTest < ActiveSupport::TestCase
    include ContestResultData

    setup do
      setup_contest_results
      PcResult.create(pilot: pilot_smith,
        category: category,
        contest: c_blue,
        hors_concours: true,
        category_value: 4080.00, total_possible: 4080)
      computer = RegionalSeries.new
      computer.compute_results(year, region)
    end

    test 'omit HC computing pilot' do
      assert_equal(3, pilot_smith.pc_results.count)
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

