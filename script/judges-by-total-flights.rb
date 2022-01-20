# This script outputs a CSV list of total pilots judged and judge name
# Usage: ruby judges-by-total-flights.rb


require 'csv'

# Hash: Key is Judge (member) ID, value is number of flights scored
jh = Hash.new

# Get the rolled-up judge experience records
JyResult.all.each do |jy|
  jh[jy.judge_id] ||= 0
  jh[jy.judge_id] += jy.pilot_count
end

CSV do |csv|

  jh.each do |jid, nf|
    member = Member.find(jid)
    csv << ["#{member.given_name} #{member.family_name}", member.iac_id, nf]
  end

end
