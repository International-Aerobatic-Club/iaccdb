# use rails runner lib/iac/runFindStars.rb 
# will check all of the contests
require "lib/iac/findStars"

Contest.all().each do |contest|
  stars = IAC::FindStars.findStars(contest)
  stars.each do |star|
    p star
  end
end

