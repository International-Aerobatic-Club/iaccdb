require 'test_helper'

require 'iac/mannyParse'

class MannySynchTest < ActiveSupport::TestCase
  @@Parsed30 = Manny::MannyParse.new
  IO.foreach("test/fixtures/Contest_30.txt") { |line| @@Parsed30.processLine(line) }
  @@Parsed31 = Manny::MannyParse.new
  IO.foreach("test/fixtures/Contest_31.txt") { |line| @@Parsed31.processLine(line) }
  @@Parsed32 = Manny::MannyParse.new
  IO.foreach("test/fixtures/Contest_32.txt") { |line| @@Parsed32.processLine(line) }

  def setup
    @mp30 = @@Parsed30
    @mp31 = @@Parsed31
    @mp32 = @@Parsed32
  end

  test "manny synch skip" do
    r = MannySynch.contest_action(@mp30.contest)
    assert_equal('skip', r[1])
    assert_not_nil(r[0])
    assert(@mp30.contest.manny_date <= r[0].synch_date)
  end

  test "manny synch update" do
    r = MannySynch.contest_action(@mp31.contest)
    assert_equal('update', r[1])
    assert_not_nil(r[0])
    assert(r[0].synch_date < @mp31.contest.manny_date)
  end

  test "manny synch create" do
    r = MannySynch.contest_action(@mp32.contest)
    assert_equal('create', r[1])
    assert_not_nil(r[0])
  end
end
