# use rails runner lib/iac/loadContestDB.rb <file>
$: << File.dirname(__FILE__)
require "manny"

ARGV.each do |f|
  manny = IAC::Manny.new
  IO.foreach(f) { |line| manny.processLine(line) }
end

