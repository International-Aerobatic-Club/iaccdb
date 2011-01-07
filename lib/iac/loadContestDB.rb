# use rails runner lib/iac/loadContestDB.rb <file>
require "lib/iac/mannyParse"
require "lib/iac/mannyToDB"

m2d = IAC::MannyToDB.new
ARGV.each do |f|
  manny = Manny::MannyParse.new
  IO.foreach(f) { |line| manny.processLine(line) }
  m2d.process_contest(manny)
end

