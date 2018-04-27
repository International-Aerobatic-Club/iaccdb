class FlightComputer
  attr_accessor :flight

  def initialize(flight)
    @flight = flight
  end

  def flight_results(has_soft_zero)
    compute_pf_results(has_soft_zero)
    compute_jf_results
  end

  def rank_computer
    IAC::RankComputer.instance
  end

  def compute_pf_results(has_soft_zero)
    cur_pf_results = rank_computer.computeFlight(@flight, has_soft_zero)
    @flight.pf_results.each do |pf_result|
      @flight.pf_results.delete(pf_result) if !cur_pf_results.include?(pf_result)
    end
    pf_results = @flight.pf_results
    cur_pf_results.each do |pf_result|
      @flight.pf_results << pf_result if !pf_results.include?(pf_result)
    end
    @flight.save!
  end

  def compute_jf_results
    cur_jf_results = rank_computer.computeJudgeMetrics(@flight)
    @flight.jf_results.each do |jf_result|
      @flight.jf_results.delete(jf_result) if !cur_jf_results.include?(jf_result)
    end
    jf_results = @flight.jf_results
    cur_jf_results.each do |jf_result|
      @flight.jf_results << jf_result if !jf_results.include?(jf_result)
    end
    @flight.save!
  end
end
