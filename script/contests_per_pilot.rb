require 'csv'

START_YEAR = 2006   # First year for which we have complete data

pdata = Hash.new


# Iterate over all contests
Contest.all.each do |contest|

  # Build the stats for each unique pilot in the contest
  PilotFlight.where(flight_id: contest.flights.pluck(:id)).pluck(:id).uniq.compact.each do |pilot_id|
    pdata[pilot_id] ||= Hash.new
    pdata[pilot_id][contest.start.year] ||= 0
    pdata[pilot_id][contest.start.year] += 1
  end

end


# Output the results
output = CSV.generate do |csv|

  pdata.each do |pilot_id, contest_years|

    next if (m = Member.find_by_id(pilot_id)).nil?

    a = [m.name]
    (START_YEAR..Time.now.year).each{ |year| a << contest_years[year] || 0 }

    csv << a

  end

end

puts output
