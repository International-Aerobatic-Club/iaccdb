require 'test_helper'
require_relative 'collegiate_test_data'

module IAC
  class TeamComputation < ActiveSupport::TestCase
    include CollegiateTestData

    setup do
      setup_collegiate_participation
    end

    test 'computes team result' do
      ctr = CollegiateTeamComputer.new(@pilot_contests)
      r = ctr.compute_result
      assert(r.qualified)
      assert_equal(6298.77, r.total)
      assert_equal(7440, r.total_possible)
      trio = r.combination.group_by { |pcr| pcr.pilot.iac_id }
      assert_equal([877212, 614888, 201845], trio.keys)
      assert_equal(3345.26, trio[877212][0].category_value)
      assert_equal(4080, trio[877212][0].total_possible)
      assert_equal(1496.34, trio[614888][0].category_value)
      assert_equal(1680, trio[614888][0].total_possible)
      assert_equal(1457.17, trio[201845][0].category_value)
      assert_equal(1680, trio[201845][0].total_possible)
    end
  end
end
