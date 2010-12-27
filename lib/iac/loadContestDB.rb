# use rails runner lib/iac/loadContestDB.rb <file>
$: << File.dirname(__FILE__)
require "mannyParse"
require "mannyModel"
require "mannyToDB"

ARGV.each do |f|
  manny = Manny::MannyParse.new
  IO.foreach(f) { |line| manny.processLine(line) }
end

