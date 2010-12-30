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
    assert_not_nil m2d.dContest
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

#  test "contest 30 personnel" do
#    contest = MP30.contest
#    ap = contest.participants
#    assert !ap.empty?
#    apid = ap.collect { |p| p ? p.iacID : 0 }
#    assert apid.include? 19517
#    assert apid.include? 432911
#    p = ap.detect { |p| p && p.iacID == 19517 }
#    assert_equal('Michael', p.givenName)
#    assert_equal('Steveson', p.familyName)
#    assert_equal(p, ap[1])
#    p = ap.detect { |p| p && p.iacID == 432911 }
#    assert_equal('Lenny', p.givenName)
#    assert_equal('Spigiel', p.familyName)
#    assert_equal(p, ap[18])
#
##    m = Member.where(:iac_id => 19517).first
##    assert m
##    assert_equal('Michael', m.given_name)
##    assert_equal('Steveson', m.family_name)
##    m = Member.where(:iac_id => 432911).first
##    assert m
##    assert_equal('Lenny', m.given_name)
##    assert_equal('Spigiel', m.family_name)
#  end
#
#  test "contest 30 flights" do
#    contest = MP30.contest
#    f1 = contest.flight(2,1)
#    assert f1
#    assert_equal("Known", f1.name)
#    f2 = contest.flight(2,2)
#    assert f2
#    assert_equal("Free", f2.name)
#  end
#
#  test "contest 30 judges" do
#    contest = MP30.contest
#    f1 = contest.flight(2,1)
#    assert_equal(1, f1.chief)
#    assert_equal(2, f1.chiefAssists.length)
#    assert f1.chiefAssists.include? 2
#    assert f1.chiefAssists.include? 3
#    assert_equal(5, f1.judges.length)
#    aj = [4, 6, 8, 10, 12]
#    aa = [5, 7, 9, 11, 13]
#    aj.each { |j| assert f1.judges.include? j }
#    aj.each_with_index { |j,i| assert_equal(aa[i], f1.assists[j]) }
#  end
#
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
#  test "contest 30 scores" do
#    contest = MP30.contest
#    f1 = contest.flight(2,1)
#    assert f1
#    assert_equal(25, f1.scores.length)
#    f2 = contest.flight(2,2)
#    assert f2
#    assert_equal(25, f2.scores.length)
#    score = f2.scores[24]
#    assert_equal(12, score.judge)
#    assert_equal(18, score.pilot)
#    assert_equal(65, score.seq.pres)
#    [70, 80, 70, 75, 60, 50,60, 50, 70, 70].each_with_index do |v,i|
#      assert_equal(v, score.seq.figs[i+1])
#    end
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

