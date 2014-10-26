require 'nokogiri'

module ACRO
class ResultScraper
include AcroWebOutputReader
include FlightIdentifier

HEADING_ROW = 3

def initialize(file)
  web_file = read_file(file)
  puts web_file
  @doc = Nokogiri::HTML(web_file)
end

def description
  cat_line = @doc.xpath('id("table1")/tr[1]').text
  parts = cat_line.partition(/: /)
  parts[2].strip
end

def category_name
  cat_line = description
  detect_flight_category(cat_line)
end

def pilots
  pilots = []
  atr = the_rows
  itr = HEADING_ROW + 1
  while (0 < atr[itr].text.strip.length && itr < atr.length) do
    pilots << atr[itr].css('td[3]').text.strip
    itr += 1
  end
  pilots
end

def flights
  flights = []
  offset = 0
  @flight_column_offset = nil
  hr = the_rows[HEADING_ROW]
  hr.css('td').each do |col|
    header = col.text.strip
    if header.length != 0 && /Rank|Pilot|plane|registration|total|all/i !~ header
      flights << header
      @flight_column_offset ||= offset
    end
    offset += 1
  end
  @flight_count = flights.length
  flights
end

def flight_total(pilot, flight)
  row = the_rows[HEADING_ROW + pilot + 1]
  columns = row.css('td')
  cell = columns[flight_column_offset + flight]
  cell.text.strip.to_f
end

def score(iFig, iJudge)
  startOffset = @hasFPSLines ? 4 : 5
  startOffset += 1 if @has2014SpreaderRow
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

def the_rows
  @doc.css('#table1').xpath('.//tr')
end

def flight_column_offset
  flights if !@flight_column_offset
  @flight_column_offset
end

end #class
end #module
