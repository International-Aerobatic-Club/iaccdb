# use rails runner
# sets hors_concours true for any pilot whose flight is the only one in category
flights = Flight.joins(:pilot_flights).group('flights.id').select(
  'flights.id, flights.contest_id, flights.category_id, count(pilot_flights.id) as flight_count')
flights = flights.all.select { |f| f.flight_count == 1 }
flights.each do |flight|
  flight.pilot_flights.each do |pf|
    pf.hors_concours = true
    pf.save!
    pcrs = PcResult.where(
        contest: flight.contest, category: flight.category, pilot: pf.pilot
      ).first
    if (pcrs)
      pcrs.hors_concours = true
      pcrs.save!
    end
  end
end

