require 'acro/pilotScraper'

module ACRO
class ContestScraper

attr_reader :dContest 
attr_reader :pDir 

def initialize(ctlFile)
  cData = YAML.load_file(ctlFile)
  cName = checkData(cData, 'contestName')
  cDate = checkData(cData, 'startDate')
  @dContest = Contest.where(:name => cName, :start => cDate).first
  if !@dContest then
    @dContest = Contest.new(
      :name => cName,
      :city => checkData(cData, 'city'),
      :state => checkData(cData, 'state'),
      :start => cDate,
      :chapter => cData['chapter'],
      :director => checkData(cData, 'director'),
      :region => cData['region'])
    @dContest.save
  end
  @pDir = Dir.new(File.dirname(ctlFile))
end

def files
  @pDir.find_all { |name| name =~ /^pilot_p\d{3}s\d\d\.htm$/ }
end

def process_pilotFlight(pScrape, reload)
  # get member records for pilot, judges
  judge_members = pScrape.judges.collect { |j| find_member(j) }
  pilot_member = find_member(pScrape.pilotName)
  # maintain mapping from flight id to flight record
  # create flight record first time id seen, infer category and flight
  # type from the flight name
end

###
private
###

def find_member(name)
  parts = name.split(' ')
  given = parts[0]
  parts.pop
  family = parts.join(' ')
  Member.find_or_create_by_name(0, given, family)
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
