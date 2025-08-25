# use rails runner
# sets hors_concours on pilot_flight, pc_result for all contests,
#   based on IAC rules

puts "This recomputes hors_concours according to IAC rules, for one contest."

cid = $*[0]
contest = if (cid)
  begin
    cid = cid.to_i
    Contest.find(cid)
  rescue ActiveRecord::RecordNotFound
    puts "There is no contest with id, #{cid} present in the database."
    nil
  end
else
  puts "Provide the id of the contest on the command line"
  nil
end

valid = if (contest)
  puts "For contest, #{contest.year_name}"
  print "Retype the id and press <enter> to verify (empty input aborts): "
  input = $stdin.gets
  input.to_i == cid
else
  false
end

if (valid)
  puts "Marking HC according to IAC rules for #{contest.year_name}"
  hc = Iac::HorsConcoursParticipants.new(contest)
  hc.mark_solo_participants_as_hc
  hc.mark_lower_category_participants_as_hc
  hc.mark_pc_results_based_on_flights
else
  puts "Nothing processed"
end
