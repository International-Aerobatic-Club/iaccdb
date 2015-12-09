module Jobs
  describe ComputeContestPilotRollupsJob do
    before(:example) do
      @contest = create(:contest)
      @job = ComputeContestPilotRollupsJob.new(@contest)
    end

    it 'creates and invokes the contest rollups' do
      expect(ContestComputer).to receive(:new).once.with(@contest).and_call_original
      @job.perform
    end

    it 'places an entry in the failure table on failure' do
      allow_any_instance_of(ContestComputer).to receive(
        :compute_contest_pilot_rollups).and_raise Exception.new('failure')
      begin
        @job.perform
      rescue Exception => e
        @job.error(@job, e)
      end
      expect(Failure.first).not_to be nil
    end
  end
end
