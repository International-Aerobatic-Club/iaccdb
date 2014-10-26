module ACRO
class CategoryResult

attr_accessor :category_name
attr_accessor :description

# array of pilot names. length is number of pilots.  zero indexed.
attr_accessor :pilots

# array of flight names. length is number of flights.  zero indexed.
attr_accessor :flight_names

# matrix of results
# flight_results[p][f] is result for pilot p on flight f, zero indexed
attr_accessor :flight_results

# array of category result totals
# category_results[p] is total for pilot p, zero indexed
attr_accessor :category_results

# array of category percentages
# category_percentages[p] is percent of points taken by pilot p, zero indexed
attr_accessor :category_percentages

# result_scraper is an ACRO::ResultScraper
def process_category_result(result_scraper)
  @category_name = result_scraper.category_name
  @description = result_scraper.description
  @pilots = result_scraper.pilots
  @flight_names = result_scraper.flights
  @flight_results = []
  @category_results = []
  @category_percentages = []
  (0 ... @pilots.size).each do |p|
    values = []
    (0 ... @flight_names.size).each do |f|
      values << result_scraper.flight_total(p, f)
    end
    @flight_results << values
    @category_results << result_scraper.result(p)
    @category_percentages << result_scraper.result_percentage(p)
  end
end

end
end
