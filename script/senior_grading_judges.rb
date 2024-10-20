require 'csv'


members = Hash.new


JfResult.includes(:judge).find_in_batches do |batch|
  batch.each do |jf_result|
    mid = jf_result.judge.judge_id
    members[mid] ||= 0
    members[mid] += 1
  end
end


Flight.find_in_batches do |batch|
  batch.each do |flight|
    mid = flight.chief_id || next
    members[mid] ||= 0
    members[flight.chief_id] += flight.pilot_flights.count
  end
end


CSV($stdout) do |csv|
  members
    .find_all{ |k,v| v > 250 }
    .map{ |mid,v| ["#{Member.find(mid).given_name} #{Member.find(mid).family_name}", mid, v] }
    .sort
    .each{ |member_name, mid, count| csv << [member_name, Member.find(mid).iac_id, count] }
end
