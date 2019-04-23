require 'test_helper'
require_relative 'collegiate_test_data'

module IAC
  class HcComputation < ActiveSupport::TestCase
    include CollegiateTestData

    setup do
      setup_collegiate_participation
      @mills_hcr = PcResult.create(pilot: @pilot_mills,
        category: @spn,
        contest: @c_michg,
        category_value: 3500.00, total_possible: 4080)
      @mills_hcr.hc_no_reason.save!
    end

    test 'omits HC computing team' do
      @team.pc_results << @mills_hcr
      @team.save
      computer = CollegiateComputer.new(@year)
      computer.recompute_team
      @team.reload
      assert_equal(6298.77, @team.points)
    end

    test 'omits HC computing individual' do
      @mills.pc_results << @mills_hcr
      @mills.save
      computer = CollegiateIndividualComputer.new(@year)
      computer.recompute
      @mills.reload
      assert_equal(9971.66, @mills.points)
      assert_equal(12240, @mills.points_possible)
    end
  end
end
