# use rails runner cmd/recompute_collegiate.rb
# will recompute collegiate team and individual results for given year

year = ARGV.empty? ? 0 : ARGV[0].to_i
if (0 < year)
  cp = Iac::CollegiateComputer.new(year)
  cp.recompute_individual
  cp.recompute_team
else
  puts 'specify a year'
end
