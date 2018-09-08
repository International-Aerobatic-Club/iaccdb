require 'test_helper'
require_relative 'contest_result_data'

module IAC
  class ComputationTest < ActiveSupport::TestCase
    include ContestResultData

    setup do
      setup_contest_results
      computer = RegionalSeries.new
      computer.compute_results(year, region)
    end

    test 'compute region result in category' do
      rt = RegionalPilot.where(
        pilot: pilot_taylor,
        region: region,
        year: year)
      refute_nil(rt)
      assert_equal(1, rt.count)
      rt = rt.first
      refute_nil(rt)
      assert_in_delta(83.02, rt.percentage)
      assert(rt.qualified)
      assert_equal(category, rt.category)
    end
  end
end
