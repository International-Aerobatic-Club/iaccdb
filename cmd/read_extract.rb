# use rails runner cmd/read_extract.rb <file>
require "acro/contest_reader"

args = ARGV
ctlFile = args[0]
if (ctlFile)
  contest_reader = ACRO::ContestReader.new(ctlFile)
  pcs = contest_reader.read_contest
  if pcs.empty?
    puts "Success reading #{contest_reader.dContest.year_name}."
    Delayed::Job.enqueue ComputeFlightsJob.new(contest_reader.dContest)
    puts "Results computation queued for processing."
  else
    puts "There were problems with these contest files:"
    pcs.each { |f| puts f }
  end
else
  puts 'Supply the name of the contest information file'
end
