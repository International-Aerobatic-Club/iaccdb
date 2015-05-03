module Jobs
describe ComputeCollegiateJob do
  before(:each) do
    @contest = create(:contest)
    @job = ComputeCollegiateJob.new(@contest)
    @cc_double = double(IAC::CollegiateComputer)
    allow(IAC::CollegiateComputer).to receive(:new).and_return(@cc_double)
  end

  it 'creates and invokes the collegiate computer' do
    expect(@cc_double).to receive(:recompute)
    @job.perform
  end

  it 'places an entry in the failure table on failure' do
    allow(@cc_double).to receive(:recompute).and_raise Exception.new('failure')
    begin
      @job.perform
    rescue Exception => e
      @job.error(@job, e)
    end
    expect(Failure.first).not_to be nil
  end

end
end
