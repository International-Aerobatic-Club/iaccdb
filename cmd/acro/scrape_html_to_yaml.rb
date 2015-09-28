# use rails runner cmd/acro/scrape_html_to_yaml.rb <control_file>

args = ARGV
ctlFile = args[0]
if (ctlFile)
  cScrape = ACRO::ContestExtractor.new(ctlFile)
  pcs = cScrape.scrape_contest
  if !pcs.empty?
    puts "There were problems with these:"
    pcs.each { |f| puts f }
  end
else
  puts 'Supply the name of the contest information file'
end

