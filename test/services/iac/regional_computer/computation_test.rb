require 'test_helper'
require_relative 'contest_result_data'

module IAC
  class ComputationTest < ActiveSupport::TestCase
    include ContestResultData

    setup do
      setup_contest_results
      @computer = RegionalSeries.new
      @computer.compute_results(year, region)
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

    context 'hc results' do
      setup do
        PcResult.create(pilot: pilot_smith,
          category: category,
          contest: c_blue,
          hors_concours: true,
          category_value: 4080.00, total_possible: 4080)
        @computer.compute_results(year, region)
      end

      should 'omit HC computing pilot' do
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

    context 'four minute' do
      setup do
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
        @computer.compute_results(year, region)
      end

      should 'omit four minute free category' do
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
end
