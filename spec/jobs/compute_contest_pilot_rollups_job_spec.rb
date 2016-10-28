module Jobs
  describe ComputeContestPilotRollupsJob do
    before(:example) do
      @contest = create(:contest)
      @job = ComputeContestPilotRollupsJob.new(@contest)
    end

    it 'creates and invokes the contest rollups' do
      computer = ContestComputer.new(@contest)
      expect(@job).to receive(:computer).once.and_return computer
      expect(computer).to receive(
        :compute_contest_pilot_rollups).once.and_call_original
      @job.perform
    end

    it 'places an entry in the failure table on failure' do
      allow(@job).to receive(
        :make_computation).and_raise Exception.new('failure')
      begin
        @job.perform
      rescue Exception => e
        @job.error(@job, e)
      end
      expect(Failure.first).not_to be nil
    end
  end
end
