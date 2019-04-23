# use rails runner
# sets hors_concours true for any pilot whose family name contains
# the string "(patch)"
pilots = Member.where('family_name like "%(patch)%"')
pilots.each do |pilot|
  pilot.pilot_flights.each do |flight|
    flight.hc_no_reason.save!
  end
  pilot.pc_results.each do |result|
    result.hc_no_reason.save!
  end
end
