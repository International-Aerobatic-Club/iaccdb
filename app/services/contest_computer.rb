class ContestComputer

  def initialize(contest)
    @contest = contest
  end

  # compute all of the flights and the contest rollups
  def compute_results
    compute_flights
    compute_contest_rollups
  end

  # compute results for all flights of the contest
  def compute_flights
    flights.each do |flight|
      flight.compute_flight_results(2014 <= year)
    end
  end

  # ensure contest rollup computations for this contest are complete
  # return array of category results
  def compute_contest_rollups
    cats = flights.collect { |f| f.category }
    cats = cats.uniq
    cats.each do |cat|
      roller = ContestRollups(@contest, cat)
      roller.compute_category_totals_and_rankings
    end
  end

end
