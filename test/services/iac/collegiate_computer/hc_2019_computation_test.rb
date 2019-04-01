require 'test_helper'
require_relative 'collegiate_test_data'

module IAC
  class Hc2019Computation < ActiveSupport::TestCase
    include CollegiateTestData

    setup do
      setup_collegiate_participation(2019)
      @mills_hcr = PcResult.create!(pilot: @pilot_mills,
        category: @spn,
        contest: @c_michg,
        category_value: 3500.00, total_possible: 4080)
    end

    test 'omits HC lower category computing team' do
      @mills_hcr.hc_higher_category.save!
      @team.pc_results << @mills_hcr
      @team.save!
      computer = CollegiateComputer.new(@year)
      computer.recompute_team
      @team.reload
      assert_equal(6298.77, @team.points)
    end

    test 'omits HC lower category computing individual' do
      @mills_hcr.hc_higher_category.save!
      @mills.pc_results << @mills_hcr
      @mills.save!
      computer = CollegiateIndividualComputer.new(@year)
      computer.recompute
      @mills.reload
      assert_equal(9971.66, @mills.points)
      assert_equal(12240, @mills.points_possible)
    end

    test 'includes HC no competition computing team' do
      @mills_hcr.hc_no_competition.save!
      @team.pc_results << @mills_hcr
      @team.save!
      computer = CollegiateComputer.new(@year)
      computer.recompute_team
      @team.reload
      assert_equal(6453.51, @team.points)
    end

    test 'includes HC no competition computing individual' do
      @mills_hcr.hc_no_competition.save!
      @mills.pc_results << @mills_hcr
      @mills.save!
      computer = CollegiateIndividualComputer.new(@year)
      computer.recompute
      @mills.reload
      assert_equal(10160.56, @mills.points)
      assert_equal(12240, @mills.points_possible)
    end
  end
end
