describe Contest, :type => :model do
  it 'cleans the contest data on reset_to_base_attributes' do
    flight = create(:flight)
    contest = flight.contest
    c_result = contest.c_results.create
    failure = contest.failures.create
    fid = flight.id
    crid = c_result.id
    faid = failure.id
    expect(Flight.find(fid)).not_to be_nil
    expect(CResult.find(crid)).not_to be_nil
    expect(Failure.find(faid)).not_to be_nil
    expect(contest.flights).not_to be_empty
    expect(contest.c_results).not_to be_empty
    expect(contest.failures).not_to be_empty
    contest.reset_to_base_attributes
    expect {Flight.find(fid)}.to raise_error(ActiveRecord::RecordNotFound)
    expect {CResult.find(crid)}.to raise_error(ActiveRecord::RecordNotFound)
    expect {Failure.find(faid)}.to raise_error(ActiveRecord::RecordNotFound)
    expect(contest.flights).to be_empty
    expect(contest.c_results).to be_empty
    expect(contest.failures).to be_empty
  end
end
