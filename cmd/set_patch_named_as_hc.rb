# use rails runner
# sets hors_concours true for any pilot whose family name contains
# the string "(patch)"
pilots = Member.where('family_name like "%(patch)%"')
pilots.each do |pilot|
  pilot.pilot_flights.each do |flight|
    flight.hors_concours = true
    flight.save!
  end
  pilot.pc_results.each do |result|
    result.hors_concours = true
    result.save
  end
end
