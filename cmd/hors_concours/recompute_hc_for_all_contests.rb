# use rails runner
# sets hors_concours on pilot_flight, pc_result for all contests,
#   based on IAC rules

Contest.all.each do |contest|
  puts "Marking HC according to IAC rules for #{contest.year_name}"
  hc = IAC::HorsConcoursParticipants.new(contest)
  hc.mark_solo_participants_as_hc
  hc.mark_lower_category_participants_as_hc
  hc.mark_pc_results_based_on_flights
end

