module Jobs
describe ComputeCollegiateJob do
  context 'for current year' do
    before(:each) do
      @contest = create(:contest, start: Time.now)
      @job = ComputeCollegiateJob.new(@contest)
    end

    it 'creates and invokes the collegiate computer' do
      expect(@job).to receive(:make_computation)
      @job.perform
    end

    it 'places an entry in the failure table on failure' do
      allow(@job).to receive(:make_computation).and_raise Exception.new('failure')
      begin
        @job.perform
      rescue Exception => e
        @job.error(@job, e)
      end
      expect(Failure.first).not_to be nil
    end
  end

  it 'does not compute past year' do
    contest = create :contest, start: Time.now - 1.year
    job = ComputeCollegiateJob.new(contest)
    expect(job).to_not receive(:make_computation)
    job.perform
  end
end
end
