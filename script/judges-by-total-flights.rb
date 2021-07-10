# This script outputs a CSV list of total pilots judged and judge name
# Usage: ruby judges-by-total-flights.rb


require 'nokogiri'
require 'open-uri'

BASE_URL = 'https://iaccdb.iac.org'
LEADERS_PAGE = "#{BASE_URL}/judges"

leaders = Array.new

# Inhale the web page
doc = Nokogiri::HTML(URI.open(LEADERS_PAGE))

doc.search('span.para-index a').each do |judge|
  leaders << [ judge.values.first, judge.text ]
end

leaders.each do |url, name|
  doc = Nokogiri::HTML(URI.open("#{BASE_URL}/#{url}"))
  puts doc.at('td:contains("All categories")').parent.at('td.count').text + ',' + name
end
