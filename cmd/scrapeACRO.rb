# use rails runner cmd/scrapeAcro.rb <file>
#require "acro/contestScraper"
#require "acro/pilotScraper"

#reload = !ARGV.empty? && ARGV[0] == 'reload'
#args = reload ? ARGV.drop(1) : ARGV
args = ARGV
ctlFile = args[0]
if (ctlFile)
  cScrape = ACRO::ContestScraper.new(ctlFile)
  pcs = cScrape.scrapeContest
  if pcs.empty?
    begin
      cScrape.dContest.results
    rescue
      puts "Trouble computing results for #{ctlFile}"
    end
  else
    puts "There were problems with these:"
    pcs.each { |f| puts f }
  end
else
  puts 'Supply the name of the contest information file'
end
