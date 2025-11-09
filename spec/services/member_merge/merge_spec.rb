module MemberMerge
describe Merge, type: :services do
  before :example do
    # mr = member record
    @mra = create_list(:member, 4)
    @mr_ids = @mra.collect(&:id)
    @target_mr = @mra[0]
    @replace_mr = @mra[1]
    @replaced_mra = Array.new(@mra).delete(@target_mr)
  end

  it 'finds existing judge pair on judge' do
    j1 = create :judge, judge: @target_mr
    j2 = create :judge, judge: @replace_mr, assist: j1.assist
    score1 = create :score, judge:j1
    score2 = create :score, judge:j2
    merge = MemberMerge::Merge.new(@mr_ids)

    expect(merge.has_overlaps).to eq false
    expect(merge.has_collisions).to eq false
    merge.execute_merge(@target_mr)

    score1.reload
    expect(score1.judge).to eq j1
    score2.reload
    expect(score2.judge).to eq j1
  end

  it 'finds existing judge pair on assistant' do
    j1 = create :judge, assist: @target_mr
    j2 = create :judge, assist: @replace_mr, judge: j1.judge
    score1 = create :score, judge:j1
    score2 = create :score, judge:j2
    merge = MemberMerge::Merge.new(@mr_ids)

    expect(merge.has_overlaps).to eq false
    expect(merge.has_collisions).to eq false
    merge.execute_merge(@target_mr)

    score1.reload
    expect(score1.judge).to eq j1
    score2.reload
    expect(score2.judge).to eq j1
  end

  it 'creates needed judge pair on judge' do
    j1 = create :judge, judge: @target_mr
    j2 = create :judge, judge: @replace_mr
    score1 = create :score, judge:j1
    score2 = create :score, judge:j2
    merge = MemberMerge::Merge.new(@mr_ids)
    merge.execute_merge(@target_mr)
    score1.reload

    expect(merge.has_overlaps).to eq false
    expect(merge.has_collisions).to eq false
    expect(score1.judge).to eq j1

    score2.reload
    new_judge = score2.judge
    expect(new_judge).to_not eq j1
    expect(new_judge).to_not eq j2
    expect(new_judge.judge).to eq @target_mr
    expect(new_judge.assist).to eq j2.assist
  end

  it 'creates needed judge pair on assistant' do
    j1 = create :judge, assist: @target_mr
    j2 = create :judge, assist: @replace_mr
    score1 = create :score, judge:j1
    score2 = create :score, judge:j2

    merge = MemberMerge::Merge.new(@mr_ids)
    expect(merge.has_overlaps).to eq false
    expect(merge.has_collisions).to eq false
    merge.execute_merge(@target_mr)

    score1.reload
    expect(score1.judge).to eq j1
    score2.reload
    new_judge = score2.judge
    expect(new_judge).to_not eq j1
    expect(new_judge).to_not eq j2
    expect(new_judge.assist).to eq @target_mr
    expect(new_judge.judge).to eq j2.judge
  end

  it 'substitutes judge pairs for scores' do
    j1 = create :judge, judge: @target_mr
    j2 = create :judge, judge: @replace_mr
    12.times { create :score, judge:j1 }
    12.times { create :score, judge:j2 }

    judge_pairs = Score.all.collect { |s| s.judge }
    expect(judge_pairs.length).to eq 24
    judges = judge_pairs.collect { |jp| jp.judge }
    judges = judges.uniq
    expect(judges.length).to eq 2
    expect(judges).to include(@target_mr)
    expect(judges).to include(@replace_mr)

    merge = MemberMerge::Merge.new(@mr_ids)
    expect(merge.has_overlaps).to eq false
    expect(merge.has_collisions).to eq false
    merge.execute_merge(@target_mr)

    judge_pairs = Score.all.collect { |s| s.judge }
    expect(judge_pairs.length).to eq 24
    judges = judge_pairs.collect { |jp| jp.judge }
    judges = judges.uniq
    expect(judges.length).to eq 1
    expect(judges).to include(@target_mr)
    expect(judges).to_not include(@replace_mr)
  end

  it 'substitutes judge pairs for jf_result' do
    j1 = create :judge, judge: @target_mr
    j2 = create :judge, judge: @replace_mr
    12.times { create :jf_result, judge:j1 }
    12.times { create :jf_result, judge:j2 }

    judge_pairs = JfResult.all.collect { |s| s.judge }
    expect(judge_pairs.length).to eq 24
    judges = judge_pairs.collect { |jp| jp.judge }
    judges = judges.uniq
    expect(judges.length).to eq 2
    expect(judges).to include(@target_mr)
    expect(judges).to include(@replace_mr)

    merge = MemberMerge::Merge.new(@mr_ids)
    expect(merge.has_overlaps).to eq false
    expect(merge.has_collisions).to eq false
    merge.execute_merge(@target_mr)

    judge_pairs = JfResult.all.collect { |s| s.judge }
    expect(judge_pairs.length).to eq 24
    judges = judge_pairs.collect { |jp| jp.judge }
    judges = judges.uniq
    expect(judges.length).to eq 1
    expect(judges).to include(@target_mr)
    expect(judges).to_not include(@replace_mr)
  end

  it 'substitutes judge pairs for pfj_result' do
    j1 = create :judge, judge: @target_mr
    j2 = create :judge, judge: @replace_mr
    12.times { create :pfj_result, judge:j1 }
    12.times { create :pfj_result, judge:j2 }

    judge_pairs = PfjResult.all.collect { |s| s.judge }
    expect(judge_pairs.length).to eq 24
    judges = judge_pairs.collect { |jp| jp.judge }
    judges = judges.uniq
    expect(judges.length).to eq 2
    expect(judges).to include(@target_mr)
    expect(judges).to include(@replace_mr)

    merge = MemberMerge::Merge.new(@mr_ids)
    expect(merge.has_overlaps).to eq false
    expect(merge.has_collisions).to eq false
    merge.execute_merge(@target_mr)

    judge_pairs = PfjResult.all.collect { |s| s.judge }
    expect(judge_pairs.length).to eq 24
    judges = judge_pairs.collect { |jp| jp.judge }
    judges = judges.uniq
    expect(judges.length).to eq 1
    expect(judges).to include(@target_mr)
    expect(judges).to_not include(@replace_mr)
  end

  context 'multiple judge pairs, scores, and jf_results' do
    before :each do
      @j1 = create :judge, judge: @target_mr
      @j2 = create :judge, judge: @replace_mr, assist: @j1.assist
      @j3 = create :judge, assist: @target_mr
      @j4 = create :judge, assist: @replace_mr, judge: @j3.judge
      4.times do
        [@j1,@j2,@j3,@j4].each do |j|
          create :score, judge:j
          create :jf_result, judge:j
        end
      end
      @merge = MemberMerge::Merge.new(@mr_ids)
    end
    it 'removes orphaned judge pairs' do
      expect(@merge.has_overlaps).to eq false
      expect(@merge.has_collisions).to eq false
      @merge.execute_merge(@target_mr)

      judges = Judge.all
      expect(judges).not_to include @j2
      expect(judges).not_to include @j4
      expect(judges).to include @j1
      expect(judges).to include @j3
    end
    it 'preserves scores' do
      scores = Score.where(judge: [@j1,@j2,@j3,@j4])
      expect(scores.count).to eq 16
      @merge.execute_merge(@target_mr)
      scores = Score.where(judge: [@j1,@j3])
      expect(scores.count).to eq 16
    end
    it 'preserves jf_results' do
      jfrs = JfResult.where(judge: [@j1,@j2,@j3,@j4])
      expect(jfrs.count).to eq 16
      @merge.execute_merge(@target_mr)
      jfrs = JfResult.where(judge: [@j1,@j3])
      expect(jfrs.count).to eq 16
    end
  end

  it 'finds existing result_member for result' do
    result = create :result
    rmassoc = create :result_member, result: result, member:@target_mr
    rma2 = create :result_member, result: result, member:@replace_mr
    rms = result.members.all
    expect(rms).to include(@target_mr)
    expect(rms).to include(@replace_mr)
    expect(@target_mr.teams).to include(result)
    expect(@replace_mr.teams).to include(result)
    merge = MemberMerge::Merge.new(@mr_ids)
    merge.execute_merge(@target_mr)
    result.reload
    rms = result.members.all
    expect(rms).to include(@target_mr)
    expect(rms).to_not include(@replace_mr)
    @target_mr.reload
    expect(@target_mr.teams).to include(result)
  end

  it 'creates needed result_member for result' do
    rmassoc = create :result_member, member:@replace_mr
    result = rmassoc.result
    expect(result.members.all).to_not include(@target_mr)
    expect(result.members.all).to include(@replace_mr)
    expect(@target_mr.teams).to_not include(result)
    expect(@replace_mr.teams).to include(result)
    merge = MemberMerge::Merge.new(@mr_ids)
    merge.execute_merge(@target_mr)
    result.reload
    expect(result.members.all).to include(@target_mr)
    expect(result.members.all).to_not include(@replace_mr)
    @target_mr.reload
    expect(@target_mr.teams).to include(result)
  end

  it 'removes orphaned result_member for result' do
    rmassoc = create :result_member, member:@target_mr
    result = rmassoc.result
    create :result_member, result: result, member:@replace_mr
    expect(result.members.all).to include(@target_mr)
    expect(result.members.all).to include(@replace_mr)
    merge = MemberMerge::Merge.new(@mr_ids)
    merge.execute_merge(@target_mr)
    mrs_count = ResultMember.where(member: @replace_mr, result: result).count
    expect(mrs_count).to be 0
  end

  it 'substitutes chief judge for flights' do
    12.times { create :flight, chief:@target_mr }
    12.times { create :flight, chief:@replace_mr }

    chief_judges = Flight.all.collect { |f| f.chief }
    expect(chief_judges.length).to eq 24
    chief_judges = chief_judges.uniq
    expect(chief_judges.length).to eq 2
    expect(chief_judges).to include(@target_mr)
    expect(chief_judges).to include(@replace_mr)

    merge = MemberMerge::Merge.new(@mr_ids)
    expect(merge.has_overlaps).to eq false
    expect(merge.has_collisions).to eq false
    merge.execute_merge(@target_mr)

    chief_judges = Flight.all.collect { |f| f.chief }
    expect(chief_judges.length).to eq 24
    chief_judges = chief_judges.uniq
    expect(chief_judges.length).to eq 1
    expect(chief_judges).to include(@target_mr)
    expect(chief_judges).to_not include(@replace_mr)
  end

  it 'substitutes chief assistant for flights' do
    12.times { create :flight, assist:@target_mr }
    12.times { create :flight, assist:@replace_mr }

    assist_judges = Flight.all.collect { |f| f.assist }
    expect(assist_judges.length).to eq 24
    assist_judges = assist_judges.uniq
    expect(assist_judges.length).to eq 2
    expect(assist_judges).to include(@target_mr)
    expect(assist_judges).to include(@replace_mr)

    merge = MemberMerge::Merge.new(@mr_ids)
    expect(merge.has_overlaps).to eq false
    expect(merge.has_collisions).to eq false
    merge.execute_merge(@target_mr)

    assist_judges = Flight.all.collect { |f| f.assist }
    expect(assist_judges.length).to eq 24
    assist_judges = assist_judges.uniq
    expect(assist_judges.length).to eq 1
    expect(assist_judges).to include(@target_mr)
    expect(assist_judges).to_not include(@replace_mr)
  end

  it 'substitutes pilot for pilot_flights' do
    12.times { create :pilot_flight, pilot:@target_mr }
    12.times { create :pilot_flight, pilot:@replace_mr }

    pilots = PilotFlight.all.collect { |f| f.pilot }
    expect(pilots.length).to eq 24
    pilots = pilots.uniq
    expect(pilots.length).to eq 2
    expect(pilots).to include(@target_mr)
    expect(pilots).to include(@replace_mr)

    merge = MemberMerge::Merge.new(@mr_ids)
    expect(merge.has_overlaps).to eq false
    expect(merge.has_collisions).to eq false
    merge.execute_merge(@target_mr)

    pilots = PilotFlight.all.collect { |f| f.pilot }
    expect(pilots.length).to eq 24
    pilots = pilots.uniq
    expect(pilots.length).to eq 1
    expect(pilots).to include(@target_mr)
    expect(pilots).to_not include(@replace_mr)
  end

  it 'substitutes pilot for regional_pilots' do
    category = create :category
    create :regional_pilot, pilot:@target_mr, category:category, year:2012
    create :regional_pilot, pilot:@replace_mr, category:category, year:2013
    expect(RegionalPilot.all.count).to eq 2

    pilots = RegionalPilot.all.collect { |f| f.pilot }
    expect(pilots.length).to eq 2
    pilots = pilots.uniq
    expect(pilots.length).to eq 2
    expect(pilots).to include(@target_mr)
    expect(pilots).to include(@replace_mr)

    merge = MemberMerge::Merge.new(@mr_ids)
    expect(merge.has_overlaps).to eq false
    expect(merge.has_collisions).to eq false
    merge.execute_merge(@target_mr)

    pilots = RegionalPilot.all.collect(&:pilot)
    expect(pilots.length).to eq 2
    pilots = pilots.uniq
    expect(pilots.length).to eq 1
    expect(pilots).to include(@target_mr)
    expect(pilots).to_not include(@replace_mr)
  end

  it 'substitutes pilot for result' do
    category = create :category
    create :result, pilot:@target_mr, category:category, year:2012
    create :result, pilot:@replace_mr, category:category, year:2013
    expect(Result.all.count).to eq 2

    pilots = Result.all.collect { |f| f.pilot }
    expect(pilots.length).to eq 2
    pilots = pilots.uniq
    expect(pilots.length).to eq 2
    expect(pilots).to include(@target_mr)
    expect(pilots).to include(@replace_mr)

    merge = MemberMerge::Merge.new(@mr_ids)
    expect(merge.has_overlaps).to eq false
    expect(merge.has_collisions).to eq false
    merge.execute_merge(@target_mr)

    pilots = Result.all.collect(&:pilot)
    expect(pilots.length).to eq 2
    pilots = pilots.uniq
    expect(pilots.length).to eq 1
    expect(pilots).to include(@target_mr)
    expect(pilots).to_not include(@replace_mr)
  end

  it 'notifies when two members have the same role on the same flight' do
    pf = create :pilot_flight, pilot:@target_mr
    create :pilot_flight, pilot:@target_mr, flight: pf.flight
    create :pilot_flight, pilot:@replace_mr, flight: pf.flight

    merge = MemberMerge::Merge.new(@mr_ids)
    expect(merge.has_collisions).to eq true
    flight_collisions = merge.flight_collisions

    expect(flight_collisions.length).to eq 1
    rf = flight_collisions.first
    expect(rf[:roles]).to eq 'Competitor'
    expect(rf[:flight]).to eq pf.flight.displayName
  end

  it 'notifies when two members have different roles on the same flight' do
    pf = create :pilot_flight, pilot:@target_mr
    jp = create :judge, judge:@replace_mr
    score = create :score, judge: jp, pilot_flight: pf

    merge = MemberMerge::Merge.new(@mr_ids)
    expect(merge.has_overlaps).to eq true
    flight_overlaps = merge.flight_overlaps

    expect(flight_overlaps.length).to eq 1
    overlap = flight_overlaps.first
    roles = overlap[:roles]
    expect(roles).to match /Competitor/
    expect(roles).to match /Line Judge/
  end

  it 'raises an exception if the target member id is not one of the members to merge' do
    mr_3 = create(:member)
    merge = MemberMerge::Merge.new(@mr_ids)
    bad_merge = proc { merge.execute_merge(mr_3) }
    expect(bad_merge).to raise_exception(ArgumentError) do |ex|
      expect(ex.message).to match('must be one of the members in the merge')
    end
  end

  context 'many flights and roles' do
    before :example do
      j = create :judge, judge: @target_mr
      create :score, judge:j
      j = create :judge, judge: @replace_mr
      create :score, judge:j

      j = create :judge, assist: @target_mr
      create :score, judge:j
      j = create :judge, assist: @replace_mr
      create :score, judge:j

      j = create :judge, judge: @target_mr
      create(:pfj_result, judge:j)
      j = create :judge, judge: @replace_mr
      create(:pfj_result, judge:j)

      j = create :judge, judge: @target_mr
      create(:jf_result, judge:j)
      j = create :judge, judge: @replace_mr
      create(:jf_result, judge:j)

      create :jy_result, judge:@target_mr
      create :jy_result, judge:@replace_mr

      create :jc_result, judge:@target_mr
      create :jc_result, judge:@replace_mr

      create :flight, chief:@target_mr
      create :flight, chief:@replace_mr
      create :flight, assist:@target_mr
      create :flight, assist:@replace_mr

      create :pilot_flight, pilot:@target_mr
      create :pilot_flight, pilot:@replace_mr

      create :result_member, member:@target_mr
      create :result_member, member:@replace_mr

      create :result, pilot:@target_mr
      create :result, pilot:@replace_mr

      create :regional_pilot, pilot:@target_mr
      create :regional_pilot, pilot:@replace_mr

      create :pc_result, pilot:@target_mr
      create :pc_result, pilot:@replace_mr
      @merge = MemberMerge::Merge.new(@mr_ids)
    end

    it 'removes the merged members' do
      expect(@merge.has_overlaps).to eq false
      expect(@merge.has_collisions).to eq false

      @merge.execute_merge(@target_mr)
      bad_merge = proc { Member.find(@replace_mr.id) }
      expect(bad_merge).to raise_exception(ActiveRecord::RecordNotFound)
      expect(Member.find(@target_mr.id)).to match(@target_mr)
    end

    it 'returns the roles and flights' do
      role_flights = @merge.role_flights
      expect(role_flights.length).to eq 5
      role_flights.each do |role_flight|
        expect(role_flight[:contest_flights].length).to eq 2
      end
    end

    it 'does not delete any scores' do
      scores_count = Score.all.count
      @merge.execute_merge(@target_mr)
      expect(Score.all.count).to eq scores_count
    end

    it 'does not delete any flights' do
      flights_count = Flight.all.count
      @merge.execute_merge(@target_mr)
      expect(Flight.all.count).to eq flights_count
    end

    it 'does not delete any pilot_flights' do
      pilot_flight_count = PilotFlight.all.count
      @merge.execute_merge(@target_mr)
      expect(PilotFlight.all.count).to eq pilot_flight_count
    end
  end
end
end
