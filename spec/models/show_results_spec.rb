describe Contest::ShowResults, :type => :model do
  before :all do
    flight = create(:flight)
    jf_result = create(:jf_result, flight: flight)
    pilot_flight = create(:pilot_flight, flight: flight)
    @contest = flight.contest
    @contest.extend(Contest::ShowResults)
  end
  it 'extends contest with organizers method' do
    orgs = @contest.organizers
    expect(orgs).not_to be_empty
    expect(orgs).to match(@contest.director)
    expect(orgs).to match(@contest.chapter.to_s)
  end
end
