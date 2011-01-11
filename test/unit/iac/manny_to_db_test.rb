require 'test_helper'
require 'iac/mannyToDB'
require 'test/unit/helpers/manny_helper'

class MannyToDBTest < ActiveSupport::TestCase
  include MannyParsedTestData

  test "contest 30 contest nil" do
    m2d = IAC::MannyToDB.new
    m2d.process_contest(MP30)
    assert_nil m2d.dContest
  end

  test "contest 30 contest update" do
    m2d = IAC::MannyToDB.new
    m2d.process_contest(MP30, true)
    assert_not_nil(m2d.dContest, "Failed update contest")
    af = m2d.dContest.flights
    assert_not_nil(af, "Failed traverse flights from contest")
    assert(!af.empty?, "Empty flights from contest")
    f = af.detect { |f| f.category == 'Sportsman' and
      f.name == 'Known' and
      f.aircat == 'G'}
    assert_not_nil(f, "Failed query flight")
    assert_equal('Steveson', f.chief.family_name)
  end

  test "contest 32 contest update" do
    m2d = IAC::MannyToDB.new
    m2d.process_contest(MP32)
    contest = m2d.dContest
    assert_not_nil(contest, "Process contest did not produce a contest record")
    assert(/^Chuck Alley Cajun Aerobatic/ =~ contest.name,
        "Contest name #{contest.name} mismatch")
    assert_equal('Estherwood', contest.city)
    assert_equal('LA', contest.state)
    assert_equal('Bubba Vidrine', contest.director)
    assert_equal(72, contest.chapter)
    assert_equal('SouthCentral', contest.region)
    assert_equal(4, contest.start.month)
    assert_equal(29, contest.start.mday)
    assert_equal(2005, contest.start.year)
  end

  test "contest 31 contest create" do
    m2d = IAC::MannyToDB.new
    m2d.process_contest(MP31)
    contest = m2d.dContest
    assert_not_nil(contest, "Process contest did not produce a contest record")
    assert(/^52nd Sebring Aerobatic Contest/ =~ contest.name, 
        "Contest name #{contest.name} mismatch")
    assert_equal('Sebring', contest.city)
    assert_equal('FL', contest.state)
    assert_equal('Mike Luszcz', contest.director)
    assert_equal(23, contest.chapter)
    assert_equal('SouthEast', contest.region)
    assert_equal(11, contest.start.month)
    assert_equal(10, contest.start.mday)
    assert_equal(2005, contest.start.year)
  end

  test "contest 31 unique members iac number zero" do
    m2d = IAC::MannyToDB.new
    m2d.process_contest(MP31, true)

    ahill = Member.where(:family_name => 'Hill', :given_name => 'Melinda')
    assert_equal(1, ahill.length)
    hill = ahill.first
    assert_equal(909090, hill.iac_id)

    ahay = Member.where(:family_name => 'Haycraft', :given_name => 'Joe')
    assert_equal(1, ahay.length)

    m2d.process_contest(MP32, true)

    awood = Member.where(:family_name => 'Wood')
    assert_equal(2, awood.length)
    jw = awood.detect { |m| m.given_name == 'Julia' }
  end

  test "contest 30" do
    m2d = IAC::MannyToDB.new
    m2d.process_contest(MP30, true)

    p = Member.where(:iac_id => 19517).first
    assert_equal('Michael', p.given_name)
    assert_equal('Stephenson', p.family_name)

    p = Member.where(:family_name => 'Steveson').first
    assert_equal('Michael', p.given_name)
    assert_equal(19517, p.iac_id)

    p = Member.where(:iac_id => 432911).first
    assert_equal('Lenny', p.given_name)
    assert_equal('Spigiel', p.family_name)

    # Pilot 14 in the Manny data
    pilot = Member.find_by_iac_id(432592)
    assert_not_nil(pilot)
    assert_equal('Travis', pilot.given_name)

    # Judge 8 in the Manny data
    pj = Member.find_by_iac_id(26409)
    assert_equal('Dornberger', pj.family_name)
    # Manny number 9
    pa = Member.find_by_iac_id(431814)
    assert_equal('Benzing', pa.family_name)

    judge = Judge.find_by_judge_id_and_assist_id(pj, pa)
    assert_not_nil(judge)
    assert_equal(pj, judge.judge)
    assert_equal(pa, judge.assist)

    ms = MannySynch.where(:manny_number => 30).first
    assert_not_nil(ms)

    contest = ms.contest
    af = contest.flights
    assert_not_nil(af)
    assert_equal(2, af.length)

    # Manny category 2, flight 1
    flight = af.detect { |f| f.name == 'Known' }
    assert_not_nil flight
    assert_equal('Sportsman', flight.category)

    apf = flight.pilot_flights
    assert_not_nil(apf)
    assert_equal(5, apf.length)

    pf = apf.detect { |pf| pf.pilot == pilot }
    assert_not_nil(pf)

    asc = pf.scores
    assert_equal(5, asc.length)

    # Manny scores 2 1 14 8
    scores = asc.detect { |sc| sc.judge == judge }
    assert_not_nil scores
    values = scores.values
    assert_not_nil values
    assert_equal(12, values.length)
    [85, 90, 90, 90, 65, 85, 95, 80, 85, 80, 80, 90].each_with_index do |v,i|
      assert_equal(v, values[i], "flight score figure #{i+1}")
    end
  end

#  test "contest 30 sequences" do
#    contest = MP30.contest
#    seq = contest.seq_for(2,1,14)
#    [17, 10, 15, 18, 10, 14, 10, 17, 11, 5, 6].each_with_index do |k,i|
#      assert_equal(k, seq.figs[i+1])
#    end
#    assert_equal(6, seq.pres)
#    assert_equal(10, seq.ctFigs)
#    assert_equal(seq, contest.seq_for(2,1,15))
#    assert_equal(seq, contest.seq_for(2,2,14))
#  end
#
#  test "contest 30 pilots" do
#    contest = MP30.contest
#    pilot = contest.pilot(2,14)
#    assert_equal("", pilot.chapter)
#    assert_equal("G-Blanik", pilot.make)
#    assert_equal("N1BA", pilot.reg)
#  end
#
#  test "contest 30 penalties" do
#    contest = MP30.contest
#    f1 = contest.flight(2,1)
#    assert_equal(250, f1.penalty(16))
#    assert_equal(0, f1.penalty(14))
#    f2 = contest.flight(2,2)
#    assert_equal(100, f2.penalty(14))
#  end
end

