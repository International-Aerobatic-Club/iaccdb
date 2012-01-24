# use rails runner lib/iac/runFindStars.rb 
# will check all of the contests
require "iac/findStars"

include IAC::Constants

year = ARGV.empty? ? 0 : ARGV[0].to_i
year = Date.today.year if year < 1990
#stars = IAC::FindStars.findStars(Contest.first())
stars = []
Contest.where('year(start) = ?', year).each do |contest|
  puts "Checking #{contest.to_s}..."
  stars += IAC::FindStars.findStars(contest)
end
puts "Sorting results..."
stars = stars.group_by { |s| "#{s[:date]}_#{s[:contest]}" }
contests = stars.keys.sort
contests.each do |ks|
  asp = stars[ks]
  start = asp[0][:date]
  name = asp[0][:contest]
  puts "#{start} #{name}"
  cats = category_split(asp)
  cats.each do |kc, asc|
    cat = asc[0][:category]
    aircat = asc[0][:aircat]
    puts "\t#{cat} #{airplane_category_name(aircat)}"
    asc.each { |s| puts "\t\t#{s[:given_name]} #{s[:family_name]} #{s[:iacID]} #{s[:scoresURL]}" }
  end
end

