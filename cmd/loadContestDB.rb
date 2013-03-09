# load the contest database from Manny files on the file system
# use rails runner lib/iac/loadContestDB.rb <file>
#require "iac/mannyParse"
#require "iac/mannyToDB"

reload = !ARGV.empty? && ARGV[0] == 'reload'
files = reload ? ARGV.drop(1) : ARGV
pcs = []
m2d = Manny::MannyToDb.new
files.each do |f|
  begin
    manny = Manny::Parse.new
    puts "Reading manny data from #{f}"
    IO.foreach(f) { |line| manny.processLine(line) }
    puts "Loading contest data from #{manny.contest.name}"
    contest = m2d.process_contest(manny, reload)
    if contest
      puts "Computing results, ranks, and metrics for #{contest.name}"
      contest.results
    else
      puts "Skipped contest #{manny.contest.name}"
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

