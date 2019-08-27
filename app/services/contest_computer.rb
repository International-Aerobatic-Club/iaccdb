class ContestComputer

  def initialize(contest)
    @contest = contest
    @flight_computer = FlightComputer.new(nil)
    @hc_computer = IAC::HorsConcoursParticipants.new(@contest)
  end

  # compute all of the flights and the contest rollups
  def compute_results
    compute_flights
    compute_judge_metrics
    compute_contest_pilot_rollups
    compute_contest_judge_rollups
  end

  # compute pilot results for all flights of the contest
  def compute_flights
    flights = @contest.flights
    flights.each do |flight|
      compute_flight_results(flight)
    end
    mark_hc_flight_participants
    @contest.save!
  end

  def mark_hc_flight_participants
    @hc_computer.mark_solo_participants_as_hc
    @hc_computer.mark_lower_category_participants_as_hc
  end

  def compute_flight_results(flight)
    @flight_computer.flight = flight
    @flight_computer.compute_pf_results(@contest.has_soft_zero)
  end

  # compute judge metrics for all flights of the contest
  def compute_judge_metrics
    flights = @contest.flights
    flights.each do |flight|
      compute_flight_judge_metrics(flight)
    end
    @contest.save!
  end

  def compute_flight_judge_metrics(flight)
    @flight_computer.flight = flight
    @flight_computer.compute_jf_results
  end

  # ensure contest pilot rollup computations for this contest are complete
  def compute_contest_pilot_rollups
    cats = @contest.flights.collect { |f| f.category }
    cats = cats.uniq
    cats.each do |cat|
      compute_category_rollups(cat)
    end
    @hc_computer.mark_pc_results_based_on_flights
    @contest.save!
  end

  def compute_category_rollups(cat)
    roller = CategoryRollups.new(@contest, cat)
    roller.compute_pilot_category_results
  end

  # ensure contest judge rollup computations for this contest are complete
  def compute_contest_judge_rollups
    cats = @contest.flights.collect { |f| f.category }
    cats = cats.uniq
    cats.each do |cat|
      roller = CategoryRollups.new(@contest, cat)
      roller.compute_judge_category_results
    end
    @contest.save!
  end

end
