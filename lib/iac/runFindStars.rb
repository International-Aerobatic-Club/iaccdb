# use rails runner lib/iac/runFindStars.rb 
# will check all of the contests
require "lib/iac/findStars"
require "lib/iac/constants"

include IAC::Constants

stars = []
Contest.all().each do |contest|
  puts "Checking #{contest.to_s}..."
  stars += IAC::FindStars.findStars(contest)
end
puts "Sorting results..."
stars = stars.sort_by { |s| [ CONTEST_CATEGORIES.index(s[:category]).to_s +
  '_' + s[:aircat] + '_' + s[:family_name] + '_' + s[:given_name], s ] }
cat = ''
aircat = ''
stars.each do |s|
  if (cat != s[:category] || aircat != s[:aircat])
    cat = s[:category]
    aircat = s[:aircat]
    puts cat + ' ' + airplane_category_name(aircat)
    fname = ''
    lname = ''
  end
  if (fname != s[:given_name] || lname != s[:family_name])
    fname = s[:given_name]
    lname = s[:family_name]
    puts "\t#{fname} #{lname} #{s[:iacID]}"
  end
  puts "\t\t#{s[:scoresURL]}"
end

