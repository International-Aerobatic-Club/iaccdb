# scrape pilot scores from ACRO produced web site files
# output yml files that contain the scores
# had to do this because could not get nokogiri installed on server
#   with proper libxml
module ACRO
class ContestExtractor

def initialize(ctlFile)
  @pDir = Dir.new(File.dirname(ctlFile))
end

def scrape_contest
  pcs = []
  pilot_files.each do |f|
    begin
      pilot_scraper = PilotScraper.new(f)
      pfd = PilotFlightData.new
      pfd.process_pilot_flight(pilot_scraper)
      File.open(f + '.yml', "w") {|out| YAML.dump(pfd, out)}
    rescue Exception => e
      pcs << report_problem(e, f)
    end
  end
  category_files.each do |f|
    begin
      result_scraper = ResultScraper.new(f)
      pcr = CategoryResult.new
      pcr.process_category_result(result_scraper)
      File.open(f + '.yml', "w") {|out| YAML.dump(pcr, out)}
    rescue Exception => e
      pcs << report_problem(e, f)
    end
  end
  pcs
end

###
  private
### 

def report_problem(exception, file_name)
  puts "\nSomething went wrong with #{file_name}:"
  puts exception.message
  exception.backtrace.each { |l| puts l }
  file_name
end

def pilot_files
  pfs = @pDir.find_all { |name| name =~ /^pilot_p\d{3}s\d\d\.htm$/ }
  pfs.collect { |fn| File.join(@pDir.path, fn) }
end

def category_files
  cfs = @pDir.find_all { |name| name =~ /^multi_\w+\.htm$/ }
  cfs.collect { |fn| File.join(@pDir.path, fn) }
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
