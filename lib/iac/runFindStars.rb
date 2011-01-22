# use rails runner lib/iac/runFindStars.rb 
# will check all of the contests
require "lib/iac/findStars"
require "lib/iac/constants"

include IAC::Constants

#stars = IAC::FindStars.findStars(Contest.first())
stars = []
Contest.all().each do |contest|
  puts "Checking #{contest.to_s}..."
  stars += IAC::FindStars.findStars(contest)
end
puts "Sorting results..."
stars = stars.group_by { |s| s[:family_name] + '_' + s[:given_name] }
names = stars.keys.sort
names.each do |ks|
  asp = stars[ks]
  fname = asp[0][:given_name]
  lname = asp[0][:family_name]
  puts "#{fname} #{lname} #{asp[0][:iacID]}"
  cats = category_split(asp)
  cats.each do |kc, asc|
    cat = asc[0][:category]
    aircat = asc[0][:aircat]
    puts "\t#{cat} #{airplane_category_name(aircat)}"
    asc.each { |s| puts "\t\t#{s[:scoresURL]}" }
  end
end

