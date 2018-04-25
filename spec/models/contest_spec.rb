describe Contest, :type => :model do
  it 'cleans the contest data on reset_to_base_attributes' do
    flight = create(:flight)
    jf_result = create(:jf_result, flight: flight)
    pilot_flight = create(:pilot_flight, flight: flight)
    contest = flight.contest
    failure = contest.failures.create
    fid = flight.id
    faid = failure.id
    jfid = jf_result.id
    pfid = pilot_flight.id
    expect(Flight.find(fid)).not_to be_nil
    expect(Failure.find(faid)).not_to be_nil
    expect(JfResult.find(jfid)).not_to be_nil
    expect(PilotFlight.find(pfid)).not_to be_nil
    expect(contest.flights).not_to be_empty
    expect(contest.failures).not_to be_empty

    contest.reset_to_base_attributes

    expect {Flight.find(fid)}.to raise_error(ActiveRecord::RecordNotFound)
    expect {Failure.find(faid)}.to raise_error(ActiveRecord::RecordNotFound)
    expect {JfResult.find(jfid)}.to raise_error(ActiveRecord::RecordNotFound)
    expect {PilotFlight.find(pfid)}.to raise_error(ActiveRecord::RecordNotFound)
    expect(contest.flights).to be_empty
    expect(contest.failures).to be_empty
  end

  context 'validations' do
    before :each do
      @valid_params = {
        'name' => 'Aéreo dust devil',
        'start' => Date.today.to_s,
        'city' => 'Daytona',
        'state' => 'CA',
        'director' => 'Cherry Garcia',
        'region' => 'SouthWest'
      }
      @long_value = 'abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz'
    end
    it 'validates presence of contest name' do
      @valid_params.delete('name')
      contest = Contest.create(@valid_params)
      expect(contest.valid?).to be false
      expect(contest.errors['name']).to_not be_empty
    end
    it 'validates max length of contest name' do
      contest = Contest.create(@valid_params.merge({name: @long_value}))
      expect(contest.valid?).to be false
      expect(contest.errors['name']).to_not be_empty
    end
    it 'validates max length of contest city' do
      contest = Contest.create(@valid_params.merge({city: @long_value}))
      expect(contest.valid?).to be false
      expect(contest.errors['city']).to_not be_empty
    end
    it 'validates max length of contest state' do
      contest = Contest.create(@valid_params.merge({state: 'USA'}))
      expect(contest.valid?).to be false
      expect(contest.errors['state']).to_not be_empty
    end
    it 'validates max length of contest director' do
      contest = Contest.create(@valid_params.merge({director: @long_value}))
      expect(contest.valid?).to be false
      expect(contest.errors['director']).to_not be_empty
    end
    it 'validates max length of contest region' do
      contest = Contest.create(@valid_params.merge({region: @long_value}))
      expect(contest.valid?).to be false
      expect(contest.errors['region']).to_not be_empty
    end
    it 'validates presence of contest start date' do
      @valid_params.delete('start')
      contest = Contest.create(@valid_params)
      expect(contest.valid?).to be false
      expect(contest.errors['start']).to_not be_empty
    end
  end
end
