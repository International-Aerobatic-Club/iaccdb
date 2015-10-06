# use rails runner cmd/read_extract.rb <file>

args = ARGV
ctlFile = args[0]
if (ctlFile)
  contest_reader = ACRO::ContestReader.new(ctlFile)
  pcs = contest_reader.read_contest
  if pcs.empty?
    puts "Success reading #{contest_reader.contest_record.year_name}."
    Delayed::Job.enqueue Jobs::ComputeFlightsJob.new(contest_reader.contest_record)
    puts "Results computation queued for processing."
  else
    puts "There were problems with these contest files:"
    pcs.each { |f| puts f }
  end
else
  puts 'Supply the name of the contest information file'
end

