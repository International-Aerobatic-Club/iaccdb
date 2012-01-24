# use rails runner cmd/read_extract.rb <file>
require "acro/contest_reader"

#reload = !ARGV.empty? && ARGV[0] == 'reload'
#args = reload ? ARGV.drop(1) : ARGV
args = ARGV
ctlFile = args[0]
if (ctlFile)
  contest_reader = ACRO::ContestReader.new(ctlFile)
  pcs = contest_reader.read_contest
  if pcs.empty?
    begin
      contest_reader.dContest.results
    rescue Exception => e
      puts "Trouble computing results for #{ctlFile} is #{e}"
    end
  else
    puts "There were problems with these:"
    pcs.each { |f| puts f }
  end
else
  puts 'Supply the name of the contest information file'
end
