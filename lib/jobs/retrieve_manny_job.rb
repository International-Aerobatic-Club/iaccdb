require 'iac/mannyParse'
require 'iac/mannyToDB'

# This captures a job for delayed job
# The job retrieves one manny record and
# parses the record into the contest database
class RetrieveMannyJob < Struct.new(:manny_id)
  
  include MannyConnect
  include JobsSay

  def perform
    say "Performing retrieve manny #{manny_id}"
    @manny_id = manny_id
    manny = Manny::MannyParse.new
    pull_contest(@manny_id, lambda { |rcd| manny.processLine(rcd) })
    m2d = IAC::MannyToDB.new
    mContest = manny.contest
    say "Parsed contest, #{mContest.name} #{mContest.record_date}"
    @contest = m2d.process_contest(manny, true)
  end

  def error(job, exception)
    say "Retrieve manny error #{manny_id}"
    Failure.create(
      :step => 'manny import', 
      :manny_id => @manny_id, 
      :description => 
        ':: ' + exception.message + ' ::\n' + exception.backtrace.join('\n'))
  end

  def success(job)
    say "Retrieve manny success #{manny_id}"
    Delayed::Job.enqueue ComputeFlightsJob.new(@contest)
  end

end
