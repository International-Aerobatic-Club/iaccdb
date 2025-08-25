# use rails runner cmd/recompute_collegiate.rb
# will recompute collegiate results for given year

year = ARGV.empty? ? 0 : ARGV[0].to_i
if (0 < year)
  collegiate_computer = Iac::CollegiateComputer.new(year)
  collegiate_computer.recompute
else
  puts 'specify a year'
end
