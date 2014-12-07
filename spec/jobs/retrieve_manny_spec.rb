module Jobs
describe RetrieveMannyJob do
  before(:each) do
    @job = RetrieveMannyJob.new(92)
  end

  it 'retrieves a contest into the database' do
    allow(@job).to receive(:pull_contest) do |manny_id, rcd_block|
      test_path = File.expand_path('../../manny/Contest_300.txt', __FILE__)
      File.open(test_path) do |input|
        input.each { |line| rcd_block.call(line) }
      end
    end
    contest = @job.perform
    expect(Contest.find(contest.id)).not_to be nil
  end

  it 'places an entry in the failure table on failure' do
    begin
      throw Exception.new('failure')
    rescue Exception => ex
      @job.error(@job, ex)
    end
    expect(Failure.first).not_to be nil
  end

  it 'queues a flight computation job on success' do
    @job.success(@job)
    jobs = Delayed::Job.all
    expect(jobs.empty?).to eq false
  end
end
end
