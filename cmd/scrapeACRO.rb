# use rails runner lib/acro/processContestToDB.rb <file>
require "acro/contestScraper"
require "acro/pilotScraper"

#reload = !ARGV.empty? && ARGV[0] == 'reload'
#args = reload ? ARGV.drop(1) : ARGV
args = ARGV
ctlFile = args[0]
if (ctlFile)
  scrapeContest(ctlFile)
else
  puts 'Supply the name of the contest information file'
end

private

def scrapeContest(ctlFile)
  cScrape = ACRO::ContestScraper.new(ctlFile)
  pcs = []
  cScrape.files.each do |f|
    begin
      pScrape = ACRO::PilotScraper.new(f)
      cScrape.process_pilotFlight(pScrape)
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
end
