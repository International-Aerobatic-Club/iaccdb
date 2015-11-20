class FlightComputer
  attr_accessible :flight

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
    self.pf_results.each do |pf_result|
      self.pf_results.delete(pf_result) if !cur_pf_results.include?(pf_result)
    end
    cur_pf_results.each do |pf_result|
      self.pf_results << pf_result if !self.pf_results.include?(pf_result)
    end
  end

  def compute_jf_results
    cur_jf_results = rank_computer.computeJudgeMetrics(@flight, self)
    self.jf_results.each do |jf_result|
      self.jf_results.delete(jf_result) if !cur_jf_results.include?(jf_result)
    end
    cur_jf_results.each do |jf_result|
      self.jf_results << jf_result if !self.jf_results.include?(jf_result)
    end
  end
end
