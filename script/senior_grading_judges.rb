def to_key(member)
  "#{member.family_name}, #{member.given_name}"
end


members = Hash.new
Member.all.each do |m|
  key = to_key m
  members[key] = 0
end


JfResult.includes(:judge).find_in_batches do |batch|

  batch.each do |jf_result|
    members[to_key(jf_result.judge.judge)] += 1
  end

end


Flight.find_in_batches do |batch|
  batch.each do |flight|
    members[to_key(flight.chief)] += flight.pilot_flights.count if flight.chief.present?
  end
end


members.find_all{ |k,v| v > 250 }.sort_by{ |k,v| k }.each{ |name, count| puts "#{name}: #{count}" }
