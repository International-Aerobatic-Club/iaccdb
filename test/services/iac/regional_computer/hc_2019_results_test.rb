require 'test_helper'
require_relative 'contest_result_data'

module IAC
  class Hc2019ResultsTest < ActiveSupport::TestCase
    include ContestResultData

    setup do
      setup_contest_results(2019)
      @solo_cat = Category.find_by(sequence: (category.sequence + 1))
      @contests = [c_blue, c_green, c_kjc]
      @pilot = create(:member)
      pcrs = @contests.collect do |ctst|
        pcr = PcResult.create(pilot: @pilot,
          category: @solo_cat,
          contest: ctst,
          category_value: 4080.00, total_possible: 4080)
        pcr.hc_no_competition.save!
        pcr
      end
      computer = RegionalSeries.new
      computer.compute_results(year, region)
    end

    test 'include HC solo in category when computing pilot' do
      assert_equal(3, @pilot.pc_results.count)
      rs = RegionalPilot.where(
        pilot: @pilot,
        region: region,
        year: year)
      refute_nil(rs)
      assert_equal(1, rs.count)
      rs = rs.first
      refute_nil(rs)
      assert_equal(@solo_cat, rs.category)
      assert_equal(@contests.length, rs.pc_results.count)
      assert_in_delta(100, rs.percentage)
      assert(rs.qualified)
    end
  end
end

