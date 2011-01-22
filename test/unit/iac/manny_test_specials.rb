require 'test_helper'
require 'iac/mannyToDB'
require 'iac/mannyParse'

class MannyTestSpecials < ActiveSupport::TestCase

  # Contest 80 had a bad record date in it
  test "contest 80 contest" do
    p80 = Manny::MannyParse.new
    IO.foreach("test/fixtures/Contest_80.txt") { |line| p80.processLine(line) }
    m2d = IAC::MannyToDB.new
    m2d.process_contest(p80, true)
    assert_not_nil(m2d.dContest, "Failed update contest")
    af = m2d.dContest.flights
    assert_not_nil(af, "Failed traverse flights from contest")
    assert(!af.empty?, "Empty flights from contest")
    f = af.detect { |f| f.category == 'Sportsman' and
      f.name == 'Known' and
      f.aircat == 'P'}
    assert_not_nil(f, "Failed query flight")
    assert_equal('Dungan', f.chief.family_name)
  end

end

