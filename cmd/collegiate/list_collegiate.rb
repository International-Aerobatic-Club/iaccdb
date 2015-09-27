# List Collegiate Teams and Participants for given year
# Use rails runner, e.g. 'rails r cmd/collegiate/list_collegiate.rb 2014'

year = ARGV.empty? ? 0 : ARGV[0].to_i
cur_year = Date.today.year
year = cur_year if cur_year < year || year < 1990
CollegiateResult.list_collegiate_for_year(year)

