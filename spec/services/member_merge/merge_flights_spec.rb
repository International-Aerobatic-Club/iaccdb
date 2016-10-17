module MemberMerge
describe MergeFlights do
  before :context do
    @flight_record = create(:flight)
    @merge_flights = MergeFlights.new
  end
  context 'accepts a flight role' do
    before :context do
      @merge_flights.add_flights_for_role(:competitor, [@flight_record])
      @rf = RoleFlight.new(:competitor, @flight_record)
    end
    it 'has role for flight' do
      roles = @merge_flights.roles_for(@flight_record)
      expect(roles.length).to eq 1
      expect(roles).to include @rf
    end
    it 'has flight for role' do
      flights = @merge_flights.flights_for(:competitor)
      expect(flights.length).to eq 1
      expect(flights).to include(@flight_record)
    end
    it 'adds to flight overlaps' do
      @merge_flights.add_flights_for_role(:assist_line_judge, [@flight_record])
      overlaps = @merge_flights.flight_overlaps
      expect(overlaps.keys.length).to eq 1
      expect(overlaps.keys).to include @flight_record
      overlap_roles = overlaps[@flight_record]
      expect(overlap_roles.length).to eq 2
      expect(overlap_roles).to include @rf
    end
    it 'adds to collisions' do
      @merge_flights.add_flights_for_role(:competitor, [@flight_record])
      collisions = @merge_flights.collisions
      expect(collisions.length).to eq 1
      expect(collisions).to include @rf
    end
  end
end
end
