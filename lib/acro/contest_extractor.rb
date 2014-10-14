# scrape pilot scores from ACRO produced web site files
# output yml files that contain the scores
# had to do this because could not get nokogiri installed on server
#   with proper libxml
module ACRO
class ContestExtractor

attr_reader :dContest 
attr_reader :pDir 

def initialize(ctlFile)
  cData = YAML.load_file(ctlFile)
  cName = checkData(cData, 'contestName')
  cDate = checkData(cData, 'startDate')
  @pDir = Dir.new(File.dirname(ctlFile))
end

def scrapeContest
  pcs = []
  files.each do |f|
    begin
      pScrape = ACRO::PilotScraper.new(f)
      pfd = process_pilotFlight(pScrape)
      File.open(f + '.yml', "w") {|out| YAML.dump(pfd, out)}
    rescue Exception => e
      puts "\nSomething went wrong with #{f}:"
      puts e.message
      e.backtrace.each { |l| puts l }
      pcs << f
    end
  end
  pcs
end

###
  private
### 

def files
  pfs = @pDir.find_all { |name| name =~ /^pilot_p\d{3}s\d\d\.htm$/ }
  pfs.collect { |fn| File.join(@pDir.path, fn) }
end

#pScrape is an ACRO::PilotScraper
def process_pilotFlight(pScrape)
  pfd = ACRO::PilotFlightData.new
  # get member records for pilot, judges
  pfd.flightID = pScrape.flightID
  pfd.flightName = pScrape.flightName
  pfd.pilotID = pScrape.pilotID
  pfd.pilotName = pScrape.pilotName
  pfd.judges = pScrape.judges
  pfd.k_factors = pScrape.k_factors
  pfd.scores = []
  (1 .. pfd.judges.size).each do |j|
    values = []
    (1 .. pfd.k_factors.size).each do |f|
      values << pScrape.score(f, j)
    end
    pfd.scores << values
  end
  pfd.penalty = pScrape.penalty
  pfd
end

def checkData(cData, field)
  datum = cData[field]
  if !datum
    raise ArgumentError, "Missing data for contest #{field}"
  end
  datum
end

end #class
end #module
