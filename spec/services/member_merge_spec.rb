describe MemberMerge, :type => :services do
  before :example do
    @mr_1 = create(:member)
    @mr_2 = create(:member)
    @merge = MemberMerge.new([@mr_1.id, @mr_2.id])
  end

  it 'finds existing judge pair on judge' do
    j1 = create :judge, judge: @mr_1
    j2 = create :judge, judge: @mr_2, assist: j1.assist
    score1 = create :score, judge:j1
    score2 = create :score, judge:j2
    
    expect(@merge.has_overlaps).to eq false
    expect(@merge.has_collisions).to eq false
    @merge.execute_merge(@mr_1)
    
    score1.reload
    expect(score1.judge).to eq j1
    score2.reload
    expect(score2.judge).to eq j1
  end

  it 'finds existing judge pair on assistant' do
    j1 = create :judge, assist: @mr_1
    j2 = create :judge, assist: @mr_2, judge: j1.judge
    score1 = create :score, judge:j1
    score2 = create :score, judge:j2
    
    expect(@merge.has_overlaps).to eq false
    expect(@merge.has_collisions).to eq false
    @merge.execute_merge(@mr_1)
    
    score1.reload
    expect(score1.judge).to eq j1
    score2.reload
    expect(score2.judge).to eq j1
  end

  it 'creates needed judge pair on judge' do
    j1 = create :judge, judge: @mr_1
    j2 = create :judge, judge: @mr_2
    score1 = create :score, judge:j1
    score2 = create :score, judge:j2
    @merge.execute_merge(@mr_1)
    score1.reload

    expect(@merge.has_overlaps).to eq false
    expect(@merge.has_collisions).to eq false
    expect(score1.judge).to eq j1

    score2.reload
    new_judge = score2.judge
    expect(new_judge).to_not eq j1
    expect(new_judge).to_not eq j2
    expect(new_judge.judge).to eq @mr_1
    expect(new_judge.assist).to eq j2.assist
  end

  it 'creates needed judge pair on assistant' do
    j1 = create :judge, assist: @mr_1
    j2 = create :judge, assist: @mr_2
    score1 = create :score, judge:j1
    score2 = create :score, judge:j2

    expect(@merge.has_overlaps).to eq false
    expect(@merge.has_collisions).to eq false
    @merge.execute_merge(@mr_1)

    score1.reload
    expect(score1.judge).to eq j1
    score2.reload
    new_judge = score2.judge
    expect(new_judge).to_not eq j1
    expect(new_judge).to_not eq j2
    expect(new_judge.assist).to eq @mr_1
    expect(new_judge.judge).to eq j2.judge
  end

  it 'substitutes judge pairs for scores' do
    j1 = create :judge, judge: @mr_1
    j2 = create :judge, judge: @mr_2
    12.times { create :score, judge:j1 }
    12.times { create :score, judge:j2 }

    judge_pairs = Score.all.collect { |s| s.judge }
    expect(judge_pairs.length).to eq 24
    judges = judge_pairs.collect { |jp| jp.judge }
    judges = judges.uniq
    expect(judges.length).to eq 2
    expect(judges).to include(@mr_1)
    expect(judges).to include(@mr_2)

    expect(@merge.has_overlaps).to eq false
    expect(@merge.has_collisions).to eq false
    @merge.execute_merge(@mr_1)

    judge_pairs = Score.all.collect { |s| s.judge }
    expect(judge_pairs.length).to eq 24
    judges = judge_pairs.collect { |jp| jp.judge }
    judges = judges.uniq
    expect(judges.length).to eq 1
    expect(judges).to include(@mr_1)
    expect(judges).to_not include(@mr_2)
  end

  it 'removes orphaned judge pairs' do
    j1 = create :judge, judge: @mr_1
    j2 = create :judge, judge: @mr_2
    j3 = create :judge, assist: @mr_1
    j4 = create :judge, assist: @mr_2
    4.times { create :score, judge:j1 }
    4.times { create :score, judge:j2 }
    4.times { create :score, judge:j3 }
    4.times { create :score, judge:j4 }

    expect(@merge.has_overlaps).to eq false
    expect(@merge.has_collisions).to eq false
    @merge.execute_merge(@mr_1)

    judges = Judge.all
    expect(judges).not_to include j2
    expect(judges).not_to include j4
    expect(judges).to include j1
    expect(judges).to include j3
  end

  it 'finds existing result_member for result' do
    result = create :result
    rmassoc = create :result_member, result: result, member:@mr_1
    rma2 = create :result_member, result: result, member:@mr_2
    rms = result.members.all
    expect(rms).to include(@mr_1)
    expect(rms).to include(@mr_2)
    expect(@mr_1.teams).to include(result)
    expect(@mr_2.teams).to include(result)
    @merge.execute_merge(@mr_1)
    result.reload
    rms = result.members.all
    expect(rms).to include(@mr_1)
    expect(rms).to_not include(@mr_2)
    @mr_1.reload
    expect(@mr_1.teams).to include(result)
  end

  it 'creates needed result_member for result' do
    rmassoc = create :result_member, member:@mr_2
    result = rmassoc.result
    expect(result.members.all).to_not include(@mr_1)
    expect(result.members.all).to include(@mr_2)
    expect(@mr_1.teams).to_not include(result)
    expect(@mr_2.teams).to include(result)
    @merge.execute_merge(@mr_1)
    result.reload
    expect(result.members.all).to include(@mr_1)
    expect(result.members.all).to_not include(@mr_2)
    @mr_1.reload
    expect(@mr_1.teams).to include(result)
  end

  it 'removes orphaned result_member for result' do
    rmassoc = create :result_member, member:@mr_1
    result = rmassoc.result
    create :result_member, result: result, member:@mr_2
    expect(result.members.all).to include(@mr_1)
    expect(result.members.all).to include(@mr_2)
    @merge.execute_merge(@mr_1)
    mrs_count = ResultMember.where(member: @mr_2, result: result).count
    expect(mrs_count).to be 0
  end

  it 'substitutes chief judge for flights' do
    12.times { create :flight, chief:@mr_1 }
    12.times { create :flight, chief:@mr_2 }

    chief_judges = Flight.all.collect { |f| f.chief }
    expect(chief_judges.length).to eq 24
    chief_judges = chief_judges.uniq
    expect(chief_judges.length).to eq 2
    expect(chief_judges).to include(@mr_1)
    expect(chief_judges).to include(@mr_2)

    expect(@merge.has_overlaps).to eq false
    expect(@merge.has_collisions).to eq false
    @merge.execute_merge(@mr_1)

    chief_judges = Flight.all.collect { |f| f.chief }
    expect(chief_judges.length).to eq 24
    chief_judges = chief_judges.uniq
    expect(chief_judges.length).to eq 1
    expect(chief_judges).to include(@mr_1)
    expect(chief_judges).to_not include(@mr_2)
  end

  it 'substitutes chief assistant for flights' do
    12.times { create :flight, assist:@mr_1 }
    12.times { create :flight, assist:@mr_2 }

    assist_judges = Flight.all.collect { |f| f.assist }
    expect(assist_judges.length).to eq 24
    assist_judges = assist_judges.uniq
    expect(assist_judges.length).to eq 2
    expect(assist_judges).to include(@mr_1)
    expect(assist_judges).to include(@mr_2)

    expect(@merge.has_overlaps).to eq false
    expect(@merge.has_collisions).to eq false
    @merge.execute_merge(@mr_1)

    assist_judges = Flight.all.collect { |f| f.assist }
    expect(assist_judges.length).to eq 24
    assist_judges = assist_judges.uniq
    expect(assist_judges.length).to eq 1
    expect(assist_judges).to include(@mr_1)
    expect(assist_judges).to_not include(@mr_2)
  end

  it 'substitutes pilot for pilot_flights' do
    12.times { create :pilot_flight, pilot:@mr_1 }
    12.times { create :pilot_flight, pilot:@mr_2 }

    pilots = PilotFlight.all.collect { |f| f.pilot }
    expect(pilots.length).to eq 24
    pilots = pilots.uniq
    expect(pilots.length).to eq 2
    expect(pilots).to include(@mr_1)
    expect(pilots).to include(@mr_2)

    expect(@merge.has_overlaps).to eq false
    expect(@merge.has_collisions).to eq false
    @merge.execute_merge(@mr_1)

    pilots = PilotFlight.all.collect { |f| f.pilot }
    expect(pilots.length).to eq 24
    pilots = pilots.uniq
    expect(pilots.length).to eq 1
    expect(pilots).to include(@mr_1)
    expect(pilots).to_not include(@mr_2)
  end

  it 'notifies when two members have the same role on the same flight' do
    pf = create :pilot_flight, pilot:@mr_1
    create :pilot_flight, pilot:@mr_2, flight: pf.flight

    expect(@merge.has_collisions).to eq true
    flight_collisions = @merge.flight_collisions

    expect(flight_collisions.length).to eq 1
    rf = flight_collisions.first
    expect(rf[:role]).to eq :competitor
    expect(rf[:flight]).to eq pf.flight
  end

  it 'notifies when two members have different roles on the same flight' do
    pf = create :pilot_flight, pilot:@mr_1
    jp = create :judge, judge:@mr_2
    score = create :score, judge: jp, pilot_flight: pf

    expect(@merge.has_overlaps).to eq true
    flight_overlaps = @merge.flight_overlaps

    expect(flight_overlaps.length).to eq 1
    flight_roles = flight_overlaps.first
    expect(flight_roles[:flight]).to eq pf.flight
    roles = flight_roles[:roles]
    expect(roles.include?(:competitor)).to eq true
    expect(roles.include?(:line_judge)).to eq true
  end

  it 'raises an exception if the target member id is not one of the members to merge' do
    mr_3 = create(:member)
    bad_merge = proc { @merge.execute_merge(mr_3) }
    expect(bad_merge).to raise_exception
  end

  context 'many flights and roles' do
    before :example do
      j = create :judge, judge: @mr_1
      create :score, judge:j
      j = create :judge, judge: @mr_2
      create :score, judge:j

      j = create :judge, assist: @mr_1
      create :score, judge:j
      j = create :judge, assist: @mr_2
      create :score, judge:j

      j = create :judge, judge: @mr_1
      create(:pfj_result, judge:j)
      j = create :judge, judge: @mr_2
      create(:pfj_result, judge:j)

      j = create :judge, judge: @mr_1
      create(:jf_result, judge:j)
      j = create :judge, judge: @mr_2
      create(:jf_result, judge:j)

      create :jy_result, judge:@mr_1
      create :jy_result, judge:@mr_2

      create :jc_result, judge:@mr_1
      create :jc_result, judge:@mr_2

      create :flight, chief:@mr_1
      create :flight, chief:@mr_2
      create :flight, assist:@mr_1
      create :flight, assist:@mr_2

      create :pilot_flight, pilot:@mr_1
      create :pilot_flight, pilot:@mr_2

      create :result_member, member:@mr_1
      create :result_member, member:@mr_2

      create :result, pilot:@mr_1
      create :result, pilot:@mr_2

      create :regional_pilot, pilot:@mr_1
      create :regional_pilot, pilot:@mr_2

      create :pc_result, pilot:@mr_1
      create :pc_result, pilot:@mr_2
    end

    it 'removes the merged members' do
      expect(@merge.has_overlaps).to eq false
      expect(@merge.has_collisions).to eq false

      @merge.execute_merge(@mr_1)
      bad_merge = proc { Member.find(@mr_2.id) }
      expect(bad_merge).to raise_exception(ActiveRecord::RecordNotFound)
      expect(Member.find(@mr_1.id)).to match(@mr_1)
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
      @merge.execute_merge(@mr_1)
      expect(Score.all.count).to eq scores_count
    end

    it 'does not delete any flights' do
      flights_count = Flight.all.count
      @merge.execute_merge(@mr_1)
      expect(Flight.all.count).to eq flights_count
    end

    it 'does not delete any pilot_flights' do
      pilot_flight_count = PilotFlight.all.count
      @merge.execute_merge(@mr_1)
      expect(PilotFlight.all.count).to eq pilot_flight_count
    end
  end
end
