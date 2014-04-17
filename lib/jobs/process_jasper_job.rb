require 'libxml'

# This captures a job for delayed job
# The job retrieves one jasper contest data submission
# parses the record into the contest database
module Jobs
class ProcessJasperJob < Struct.new(:data_post_id)
  
  include JobsSay

  def perform
    say "Performing process JaSPer data post #{data_post_id}"
    post_record = DataPost.find(data_post_id)
    parser = LibXML::XML::Parser.file(post_record.filename)
    jasper = Jasper::JasperParse.new
    jasper.do_parse(parser)
    @contest_id = jasper.contest_id
    say "Parsed contest, #{jasper.contest_name} #{jasper.contest_date}"
    @record_year = jasper.contest_date.year
    j2d = Jasper::JasperToDB.new
    @contest = j2d.process_contest(jasper)
    post_record.is_integrated = true
    post_record.save
  end

  def error(job, exception)
    say "Process JaSPer post data, error #{data_post_id}"
    record_post_failure('process jasper', data_post_id, @contest_id, exception)
  end

  def success(job)
    say "Process JaSPer success #{data_post_id}, #{@contest.to_s}"
    if @contest
      Delayed::Job.enqueue ComputeFlightsJob.new(@contest)
    else
      Delayed::Job.enqueue ComputeYearRollupsJob.new(@record_year)
    end
  end

end
end
