require 'nokogiri'

module ACRO
class PilotScraper

attr_reader :pilotID
attr_reader :flightID

def initialize(file)
  filtered = ""
  File.open(file,'r') do |f|
    # the ACRO outputs have missing font end tags
    # the non-breaking spaces don't encode as white space to strip
    f.each_line { |l| filtered << l.gsub(/<font[^>]+>|<\/font>|&nbsp;/,' ') }
  end
  @doc = Nokogiri::HTML(filtered)
  flds = /p(\d+)s(\d+)/.match(file)
  @pilotID = flds[1].to_i
  @flightID = flds[2].to_i
  @hasFPSLines = /FairPlay/.match(@doc.xpath('id("table7")/tr[1]').text) != nil
end

def pilotName
  pilotLine = @doc.xpath('id("table7")/tr[2]')
  aStr = pilotLine.text.strip.split(' ')
  aStr[0] + ' ' + aStr[1]
end

def flightName
  flightLine = @doc.xpath('id("table7")/tr[3]')
  flightLine.text.strip
end

def judges
  judgeLine = @doc.xpath('id("table7")/tr[6]')
  nStr = judgeLine.text.strip
  nStr.split(',').collect do |s|
    s[s.index('-')+2,s.length]
  end
end

def k_factors
  ks = []
  ar = rawRows
  startOffset = @hasFPSLines ? 5 : 6
  endOffset = @hasFPSLines ? 3 : 2
  (startOffset .. ar.size-endOffset).each do |itr|
    nStr = ar[itr].css('td')[1].text.strip
    ks << nStr.to_i
  end
  ks
end

def score(iFig, iJudge)
  startOffset = @hasFPSLines ? 4 : 5
  s = 0
  ar = rawRows
  nTD = ar[iFig + startOffset].css('td')[iJudge + 1]
  childSet = nTD.xpath('.//text()')
  nGrade = childSet.last
  nStr = nGrade.text.strip if nGrade
  unless nStr =~ /Z/
    s = nStr.to_f * 10
    s = s.to_i
  end
  s
end

def penalty
  pr = penaltyRow
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

def rawRows
  @doc.xpath('id("table7")/tr[td[@bgcolor]]')
end

def penaltyRow
  @doc.xpath('id("table7")/tr[td[contains(.,"penalties")]]');
end

end #class
end #module
