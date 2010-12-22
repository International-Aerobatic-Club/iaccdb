require 'test_helper'
require 'iac/mannyParse'

class MannyTest < ActiveSupport::TestCase
  @@Parsed30 = Manny::MannyParse.new
  IO.foreach("test/fixtures/Contest_30.txt") { |line| @@Parsed30.processLine(line) }

  def setup
    @mparse = @@Parsed30
  end

  test "contest 30 contest" do
    contest = @mparse.contest
    assert contest
    assert_equal(30, contest.mannyID)
    assert_equal('G', contest.aircat)
    assert /^2006 Copperstate/ =~ contest.name
    assert_equal('Coolidge', contest.city)
    assert_equal('AZ', contest.state)
    assert_equal('03/30/2006', contest.dateAdv)
    assert_equal('George Norris', contest.director)
    assert_equal('69', contest.chapter)
    assert_equal('SouthWest', contest.region)
    assert /^5\/4\/2006/ =~ contest.manny_date
    assert_equal('3/30/2006', contest.record_date)
  end

  test "contest 30 personnel" do
    contest = @mparse.contest
    ap = contest.participants
    assert !ap.empty?
    apid = ap.collect { |p| p ? p.iacID : 0 }
    assert apid.include? 19517
    assert apid.include? 432911
    p = ap.detect { |p| p && p.iacID == 19517 }
    assert_equal('Michael', p.givenName)
    assert_equal('Steveson', p.familyName)
    assert_equal(p, ap[1])
    p = ap.detect { |p| p && p.iacID == 432911 }
    assert_equal('Lenny', p.givenName)
    assert_equal('Spigiel', p.familyName)
    assert_equal(p, ap[18])

#    m = Member.where(:iac_id => 19517).first
#    assert m
#    assert_equal('Michael', m.given_name)
#    assert_equal('Steveson', m.family_name)
#    m = Member.where(:iac_id => 432911).first
#    assert m
#    assert_equal('Lenny', m.given_name)
#    assert_equal('Spigiel', m.family_name)
  end

  test "contest 30 flights" do
    contest = @mparse.contest
    f1 = contest.flight(2,1)
    assert f1
    assert_equal("Known", f1.name)
    f2 = contest.flight(2,2)
    assert f2
    assert_equal("Free", f2.name)
  end

  test "contest 30 judges" do
    contest = @mparse.contest
    f1 = contest.flight(2,1)
    assert_equal(1, f1.chief)
    assert_equal(2, f1.chiefAssists.length)
    assert f1.chiefAssists.include? 2
    assert f1.chiefAssists.include? 3
    assert_equal(5, f1.judges.length)
    aj = [4, 6, 8, 10, 12]
    aa = [5, 7, 9, 11, 13]
    aj.each { |j| assert f1.judges.include? j }
    aj.each_with_index { |j,i| assert_equal(aa[i], f1.assists[j]) }
  end

  test "contest 30 sequences" do
    contest = @mparse.contest
    seq = contest.seq_for(2,1,14)
    [17, 10, 15, 18, 10, 14, 10, 17, 11, 5, 6].each_with_index do |k,i|
      assert_equal(k, seq.figs[i+1])
    end
    assert_equal(6, seq.pres)
    assert_equal(10, seq.ctFigs)
    assert_equal(seq, contest.seq_for(2,1,15))
    assert_equal(seq, contest.seq_for(2,2,14))
  end

  test "contest 30 pilots" do
    contest = @mparse.contest
    pilot = contest.pilot(2,14)
    assert_equal("", pilot.chapter)
    assert_equal("G-Blanik", pilot.make)
    assert_equal("N1BA", pilot.reg)
  end

  test "contest 30 scores" do
    contest = @mparse.contest
    f1 = contest.flight(2,1)
    assert f1
    assert_equal(25, f1.scores.length)
    f2 = contest.flight(2,2)
    assert f2
    assert_equal(25, f2.scores.length)
    score = f2.scores[24]
    assert_equal(12, score.judge)
    assert_equal(18, score.pilot)
    assert_equal(65, score.seq.pres)
    [70, 80, 70, 75, 60, 50,60, 50, 70, 70].each_with_index do |v,i|
      assert_equal(v, score.seq.figs[i+1])
    end
  end

  test "contest 30 penalties" do
    contest = @mparse.contest
    f1 = contest.flight(2,1)
    assert_equal(250, f1.penalty(16))
    assert_equal(0, f1.penalty(14))
    f2 = contest.flight(2,2)
    assert_equal(100, f2.penalty(14))
  end
end

