require 'test_helper'
require_relative 'collegiate_test_data'

module IAC
  class Hc2019Computation < ActiveSupport::TestCase
    include CollegiateTestData

    setup do
      setup_collegiate_participation(2019)
      @mills_hcr = PcResult.create(pilot: @pilot_mills,
        category: @spn,
        contest: @c_michg,
        hors_concours: true,
        category_value: 3500.00, total_possible: 4080)
    end

    test 'includes HC computing team' do
      @team.pc_results << @mills_hcr
      @team.save
      computer = CollegiateComputer.new(@year)
      computer.recompute_team
      @team.reload
      assert_equal(6453.51, @team.points)
    end

    test 'includes HC computing individual' do
      @mills.pc_results << @mills_hcr
      @mills.save
      computer = CollegiateIndividualComputer.new(@year)
      computer.recompute
      @mills.reload
      assert_equal(10160.56, @mills.points)
      assert_equal(12240, @mills.points_possible)
    end
  end
end
