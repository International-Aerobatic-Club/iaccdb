require 'nokogiri'

module ACRO
class PilotScraper

attr_reader :pilotID
attr_reader :flightID

def initialize(file)
  File.open(file,'r') do |f|
    @doc = Nokogiri::HTML.parse(f)
  end
  flds = /p(\d+)s(\d+)/.match(file)
  @pilotID = flds[1].to_i
  @flightID = flds[2].to_i
end

def pilotName
  nStr = theRows[2].text.strip.split(/\s\s+/)[0]
  nStr[2,nStr.length]
end

def flightName
  nStr = theRows[3].text.strip
  nStr[2,nStr.length]
end

def judges
  nStr = theRows[6].text.strip
  nStr.split(',').collect do |s|
    s[s.index('-')+2,s.length]
  end
end

def k_factors
  ks = []
  ar = theRows
  (8 .. ar.size-8).each do |itr|
    nStr = ar[itr].css('td')[1].text.strip
    ks << nStr.to_i
  end
  ks
end

def score(iFig, iJudge)
  s = 0
  ar = theRows
  nStr = ar[iFig + 7].css('td')[iJudge + 1].text.strip
  unless nStr =~ /Z/
    s = nStr.to_f * 10
    s = s.to_i
  end
  s
end

def penalty
  ar = theRows
  pr = ar[ar.size-4]
  mp = /Minus\s+(\d+)\s+penalties/.match(pr.text)
  if mp
    mp[1].to_i
  else
    0
  end
end

###
private
###

def theRows
  @doc.css('table#table7 tr')
end

end #class
end #module
