# From P&P 501.4.1:
# All National Judges, and those Regional Judges who have logged 250 or more flights, as
# published in the IAC Contest Database (IACCDB) at the end of the previous contest year, will be
# invited to judge at the U.S. Nationals.

# This script reads the list of current judges from STDIN, in the format produced by www.iac.org/current-judges-csv
# Usage: cd ~www-data/iaccdb; bin/rails r script/nationals-eligible-judges.rb < current-judges.csv

require 'csv'

CSV.parse(STDIN.read, headers: true) do |row|

  # Get their IAC number
  iacnum = row['IAC #']

  # National judges need to no further checks
  if row['Type'] == 'National'
    puts iacnum
    next
  end

  # Get their Member.id value
  member = Member.find_by_iac_id(iacnum)

  if member.nil?
    STDERR.puts "** No record for IAC# #{iacnum}; skipping"
    next
  end

  puts iacnum if Score.where(judge_id: Judge.where(judge_id: member.id).pluck(:id)).count >= 250

end
