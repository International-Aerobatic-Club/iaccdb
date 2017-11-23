module MemberMerge
describe RoleFlight do
  before :context do
    @flight_record = create(:flight)
  end
  context 'constructor' do
    it 'raises argument error given invalid role' do
      expect{ RoleFlight.new(:fake, @flight_record) }.to raise_error(
        ArgumentError)
    end
    it 'raises argument error given nil flight' do
      expect{ RoleFlight.new(:competitor, nil) }.to raise_error(
        ArgumentError)
    end
    it 'raises argument error given unsaved flight' do
      expect{ RoleFlight.new(:competitor, build(:flight)) }.to raise_error(
        ArgumentError)
    end
  end
  context 'collisions' do
    def check_no_match(rf1, rf2)
      expect(rf1.hash).to_not eq rf2.hash
      expect(rf1 == rf2).to be false
      expect(rf1).to_not eql rf2
      set = Set.new
      set.add(rf1)
      expect(set.include?(rf2)).to be false
      expect(set.add?(rf2)).to be set
    end
    it 'matches instances with same role and flight' do
      rf1 = RoleFlight.new(:competitor, @flight_record)
      rf2 = RoleFlight.new(:competitor, @flight_record)
      expect(rf1.hash).to eq rf2.hash
      expect(rf1 == rf2).to be true
      expect(rf1).to eql rf2
      set = Set.new
      set.add(rf1)
      expect(set.include?(rf2)).to be true
      expect(set.add?(rf2)).to be nil
    end
    it 'does not match instances with same role, different flight' do
      rf1 = RoleFlight.new(:competitor, @flight_record)
      rf2 = RoleFlight.new(:competitor, create(:flight))
      check_no_match(rf1, rf2)
    end
    it 'does not match instances with different role, same flight' do
      rf1 = RoleFlight.new(:competitor, @flight_record)
      rf2 = RoleFlight.new(:line_judge, @flight_record)
      check_no_match(rf1, rf2)
    end
    it 'does not match instances with different role, different flight' do
      rf1 = RoleFlight.new(:competitor, @flight_record)
      rf2 = RoleFlight.new(:line_judge, create(:flight))
      check_no_match(rf1, rf2)
    end
    it 'does not collide 4438 assist and 8876 line' do
      flight_4438 = Flight.new
      flight_4438.id = 4438
      flight_8876 = Flight.new
      flight_8876.id = 8876
      role_flight_4438 = RoleFlight.new(:assist_line_judge, flight_4438)
      role_flight_8876 = RoleFlight.new(:line_judge, flight_8876)
      check_no_match(role_flight_4438, role_flight_8876)
    end
  end
  it 'class provides list of valid roles' do
    roles = RoleFlight.roles
    expect(roles).to include(:line_judge)
    expect(roles).to include(:competitor)
  end
  it 'instance provides list of valid roles' do
    roles = RoleFlight.new(:line_judge, @flight_record).roles
    expect(roles).to include(:assist_chief_judge)
    expect(roles).to include(:assist_line_judge)
  end
  it 'class translates role for display' do
    expect(RoleFlight.role_name(:line_judge)).to eq 'Line Judge'
    expect(RoleFlight.role_name(:competitor)).to eq 'Competitor'
  end
  it 'instance translates role for display' do
    expect(RoleFlight.new(:chief_judge, @flight_record).role_name).to eq(
      'Chief Judge')
    expect(RoleFlight.new(:assist_chief_judge, @flight_record).role_name).to eq(
      'Chief Judge Assistant')
  end
  context 'attributes' do
    before :context do
      @rf = RoleFlight.new(:competitor, @flight_record)
    end
    it 'instance references contest' do
      expect(@rf.contest).to eq @flight_record.contest
    end
    it 'instance references flight' do
      expect(@rf.flight).to eq @flight_record
    end
    it 'instance references role' do
      expect(@rf.role).to eq :competitor
    end
  end
end
end
