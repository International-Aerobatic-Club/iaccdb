class CategoryRollups
  def initialize(contest, category)
    @contest = contest
    @category = category
  end

  # return flights for this category of this contest
  def flights
    @contest.flights.where(:category => @category)
  end

  # compute all pilot and judge category rollups
  # compute pilot rankings
  # for this category of this contest
  def compute_category_totals_and_rankings
    cat_flights = flights
    pc_results = compute_pilot_category_results(cat_flights)
    jc_results = compute_judge_category_results(cat_flights)
    compute_category_ranks(pc_results)
  end

  # compute pilot rankings
  # for this category of this contest
  def compute_pilot_rankings
    pc_results = @contest.pc_results.where(:category => @category)
    compute_category_ranks(pc_results)
  end

  # compute pilot results
  # for this category of this contest
  # cat_flights: flights in category
  # returns set of pc_result
  def compute_pilot_category_results(cat_flights)
    cur_pc_results = Set.new
    pc_results = @contest.pc_results.where(:category => @category)
    cat_flights.each do |flight|
      cur_pc_results |= pc_results_for_flight(flight)
    end
    pc_results.each do |pc_result|
      unless cur_pc_results.include?(pc_result)
        pc_result.delete
      end
    end
    cur_pc_results.each do |pc_result|
      pc_result.compute_category_totals
    end
    cur_pc_results
  end

  # compute judge results
  # for this category of this contest
  # cat_flights: flights in category
  # returns set of jc_result
  def compute_judge_category_results(cat_flights)
    cur_jc_results = Set.new
    jc_results = @contest.jc_results.where(:category => @category)
    cat_flights.each do |flight|
      cur_jc_results |= jc_results_for_flight(flight)
    end
    jc_results.each do |jc_result|
      unless cur_jc_results.include?(jc_result)
        jc_results.delete(jc_result)
      end
    end
    cur_jc_results.each do |jc_result|
      jc_result.compute_category_totals
    end
    cur_jc_results
  end

  def to_s
    "CategoryRollups for #{@contest}, #{@category}"
  end

  ###
  private
  ###

  def logger
    Rails.logger
  end

  # find or creates pc_result for every pilot on the flight
  # pc_results: existing result set
  def pc_results_for_flight(flight)
    rpc_results = []
    flight.pilot_flights.each do |pilot_flight|
      pilot = pilot_flight.pilot
      pc_result = @contest.pc_results.where(
        pilot: pilot, category: @category).first
      if !pc_result
        pc_result = @contest.pc_results.create(
          category: @category, pilot: pilot)
      end
      rpc_results << pc_result
    end
    rpc_results.to_set
  end

  def jc_results_for_flight(flight)
    rjc_results = []
    flight.jf_results.each do |jf_result|
      judge = jf_result.judge.judge
      jc_result = @contest.jc_results.where(
        category: @category, judge: judge).first
      if !jc_result
        jc_result = @contest.jc_results.create(
          category: @category, judge: judge)
      end
      rjc_results << jc_result
    end
    rjc_results.to_set
  end

  # Compute rank for each pilot in a contest category
  def compute_category_ranks(pc_results)
    logger.info "Computing ranks for #{self}"
    category_values = []
    pc_results.each do |pc_result|
      category_values << pc_result.category_value
    end
    begin
      category_ranks = Ranking::Computer.ranks_for(category_values)
      pc_results.each_with_index do |pc_result, i|
        pc_result.category_rank = category_ranks[i]
        pc_result.save
      end
    rescue Exception => exception
      logger.error exception.message
      Failure.create(
        :step => "category",
        :contest_id => contest.id,
        :manny_id => contest.manny_synch ? contest.manny_synch.manny_number : nil,
        :description => 
          ":: " + self.to_s +
          "\n:: category_values " + category_values.to_yaml +
          "\n:: #{exception.message} ::\n" + exception.backtrace.join("\n"))
    end
  end
end
