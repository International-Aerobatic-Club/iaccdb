# use rails runner cmd/recompute_regionals.rb
# will recompute soucy results for given year

year = ARGV.empty? ? 0 : ARGV[0].to_i
if (0 < year)
  soucy = IAC::SoucyComputer.new(year)
  soucy.recompute
else
  puts 'specify a year'
end
