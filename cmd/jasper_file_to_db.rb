# load the contest database from JaSPer files on the file system
# use rails runner cmd/jasperFileToDB.rb <file>
require "iac/jasperParse"
require "iac/jasperToDB"
require 'xml'

files = ARGV
pcs = []
j2d = IAC::JaSPerToDB.new
files.each do |f|
  begin
    jasper = JaSPer::JaSPerParse.new
    puts "Reading JaSPer data from #{f}"
    parser = XML::Parser.file(f)
    jasper.do_parse(parser)
    contest = j2d.process_contest(jasper)
    if contest
      puts "Computing results, ranks, and metrics for #{contest.name}"
      contest.results
    else
      puts "Skipped contest, \"#{jasper.contest_name}\" from #{f}"
      pcs << f
    end
  rescue Exception => e
    puts "\nSomething went wrong with #{f}:"
    puts e.message
    e.backtrace.each { |l| puts l }
    pcs << f
  end
end
unless pcs.empty?
  puts "There were problems with these:"
  pcs.each { |f| puts f }
end
