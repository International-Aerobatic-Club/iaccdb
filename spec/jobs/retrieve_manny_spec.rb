module Jobs
describe RetrieveMannyJob do
  before(:each) do
    @job = RetrieveMannyJob.new(92)
  end
  it 'retrieves a contest into the database' do
    contest = @job.perform
    Contest.find(contest.id).should_not be nil
  end

  it 'places an entry in the failure table on failure' do
    begin
      throw Exception.new('failure')
    rescue Exception => ex
      @job.error(@job, ex)
    end
    Failure.first.should_not be nil
  end

  it 'queues a flight computation job on success' do
    @job.success(@job)
    jobs = Failure.select('* from delayed_jobs')
    jobs.empty?.should be_false
  end
end
end
