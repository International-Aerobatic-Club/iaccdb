require 'test_helper'
require 'test/unit/helpers/manny_helper'

class MannySynchTest < ActiveSupport::TestCase
  include MannyParsedTestData

  test "manny synch skip" do
    r = MannySynch.contest_action(MP30.contest)
    assert_not_nil(r[0])
    assert(MP30.contest.manny_date <= r[0].synch_date)
    assert_equal('skip', r[1])
  end

  test "manny synch update" do
    r = MannySynch.contest_action(MP32.contest)
    assert_not_nil(r[0])
    assert(r[0].synch_date < MP32.contest.manny_date)
    assert_equal('update', r[1])
  end

  test "manny synch create" do
    r = MannySynch.contest_action(MP31.contest)
    assert_not_nil(r[0])
    assert_equal('create', r[1])
  end
end
