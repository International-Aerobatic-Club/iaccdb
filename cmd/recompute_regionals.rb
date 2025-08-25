# use rails runner cmd/recompute_regionals.rb
# will recompute regional results for given year
require "iac/regional_series"

year = ARGV.empty? ? 0 : ARGV[0].to_i
if (0 < year)
  series = Iac::RegionalSeries.new
  series.compute_all_regions year
else
  puts 'specify a year'
end
