require 'iac/mannyParse'
require 'iac/mannyToDB'
require 'time'

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
    say "Parsed contest, #{mContest.name} #{mContest.record_date}, code #{mContest.code}"
    @record_year = mContest.record_date.year
    @contest = m2d.process_contest(manny, true)
  end

  def error(job, exception)
    say "Retrieve manny error #{@manny_id}"
    record_manny_failure('retrieve manny', @manny_id, exception)
  end

  def success(job)
    say "Retrieve manny success #{manny_id}"
    if @contest
      Delayed::Job.enqueue ComputeFlightsJob.new(@contest)
    else
      Delayed::Job.enqueue ComputeYearRollupsJob.new(@record_year)
    end
  end

end
