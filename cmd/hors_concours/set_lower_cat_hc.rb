# use rails runner
# sets hors_concours true on all but highest category for any pilot flying
#   multiple categories at a contest
# some care is needed because a competitor can fly both power and glider

def mark_flights(pc_result)
  flight = Flight.where(contest: pc_result.contest,
    category: pc_result.category).first
  pilot_flights = PilotFlight.where(pilot: pc_result.pilot,
    flight: flight)
  pilot_flights.each do |pf|
    pf.hors_concours = true
    pf.save!
  end
end

pcrs = PcResult.select(
    'id, pilot_id, contest_id, count(category_id) as cats'
  ).group('pilot_id, contest_id')
pcrs = pcrs.all.select { |pcr| 1 < pcr.cats }
pcrs.each do |pcr|
  cats = PcResult.joins(:category).where(
    pilot_id: pcr.pilot_id, contest_id: pcr.contest_id
  ).order('categories.sequence')
  catsg = cats.all.group_by do |cat|
    cat.category.aircat
  end
  catsg.each do |pgcat, results|
    results[0...-1].each do |result|
      result.hors_concours = true
      result.save!
      mark_flights(result)
    end
  end
end

