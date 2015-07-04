module Jobs
describe ComputeContestRollupsJob do
  before(:example) do
    @contest = create(:contest)
    @job = ComputeContestRollupsJob.new(@contest)
  end

  it 'creates and invokes the contest rollups' do
    expect(@contest).to receive(:compute_contest_rollups).at_least(:once).and_call_original
    @job.perform
  end

  it 'places an entry in the failure table on failure' do
    allow(@contest).to receive(:compute_contest_rollups).and_raise Exception.new('failure')
    begin
      @job.perform
    rescue Exception => e
      @job.error(@job, e)
    end
    expect(Failure.first).not_to be nil
  end

end
end
