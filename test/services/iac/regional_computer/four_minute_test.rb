require 'test_helper'
require_relative 'contest_result_data'

module IAC
  class FourMinuteTest < ActiveSupport::TestCase
    include ContestResultData

    setup do
      setup_contest_results
      four = Category.find_for_cat_aircat('four minute', 'F')
      @pilot_dumovic = Member.create(
        iac_id: 21224,
        given_name: 'Robert', 
        family_name: 'Dumovic')
      PcResult.create(pilot: @pilot_dumovic,
        category: four,
        contest: c_blue,
        category_value: 3500.00, total_possible: 4000)
      PcResult.create(pilot: @pilot_dumovic,
        category: four,
        contest: c_green,
        category_value: 2500.00, total_possible: 4000)
      PcResult.create(pilot: @pilot_dumovic,
        category: four,
        contest: c_kjc,
        category_value: 3000.00, total_possible: 4000)
      computer = RegionalSeries.new
      computer.compute_results(year, region)
    end

    test 'omit four minute free category' do
      assert_equal(3, @pilot_dumovic.pc_results.count)
      rs = RegionalPilot.where(
        pilot: @pilot_dumovic,
        region: region,
        year: year)
      refute_nil(rs)
      assert_equal(0, rs.count)
    end
  end
end
