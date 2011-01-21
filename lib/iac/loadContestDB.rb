# use rails runner lib/iac/loadContestDB.rb <file>
require "lib/iac/mannyParse"
require "lib/iac/mannyToDB"

pcs = []
m2d = IAC::MannyToDB.new
ARGV.each do |f|
  begin
    manny = Manny::MannyParse.new
    IO.foreach(f) { |line| manny.processLine(line) }
    m2d.process_contest(manny)
  rescue Exception => e
    puts "\nSomething went wrong with #{f}:"
    puts e.message
    e.backtrace.each { |l| puts l }
    pcs << f
  end
end
if !pcs.empty? do
  puts "There were problems with these:"
  pcs.each { |f| puts f }
end

