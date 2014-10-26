require 'nokogiri'

module ACRO
class ResultScraper
include AcroWebOutputReader
include FlightIdentifier

HEADING_ROW = 3

def initialize(file)
  web_file = read_file(file)
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
  columns = pilot_columns(pilot)
  cell = columns[flight_column_offset + flight]
  cell.text.to_f
end

def result(pilot)
  columns = pilot_columns(pilot)
  cell = columns[flight_column_offset + @flight_count]
  cell.text.to_f
end

def result_percenage(pilot)
  columns = pilot_columns(pilot)
  cell = columns[flight_column_offset + @flight_count + 1]
  cell.text.to_f
end

###
private
###

def the_rows
  @doc.css('#table1').xpath('.//tr')
end

def pilot_columns(pilot)
  the_rows[HEADING_ROW + pilot + 1].css('td')
end

def flight_column_offset
  flights if !@flight_column_offset
  @flight_column_offset
end

end #class
end #module
