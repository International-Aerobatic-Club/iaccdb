class PcResult < ActiveRecord::Base
  attr_protected :id

  belongs_to :pilot, :class_name => 'Member'
  belongs_to :c_result
  has_many :pf_results
  has_many :region_contests
  has_many :regional_pilots, :through => :region_contests

  def to_s 
    a = "pc_result for pilot #{pilot} value #{category_value}, "
    a += "pilot_flight results [\n\t#{pf_results.join("\n\t")}\n]" if pf_results
  end

  def category
    c_result.category
  end

  def year
    c_result.year
  end

  def region
    c_result.region
  end

  def contest
    c_result.contest
  end

  def pct_possible
    category_value * 100.0 / total_possible
  end

  def compute_category_totals(f_results)
    self.category_value = 0
    self.total_possible = 0
    cur_pf_results = []
    f_results.each do |f_result|
      f_result.pf_results.each do |pf_result|
        cur_pf_results << pf_result if pf_result.pilot_flight.pilot == pilot
      end
    end
    cur_pf_results.each do |pf_result|
      self.category_value += pf_result.adj_flight_value
      self.total_possible += pf_result.total_possible
      pf_results << pf_result if !pf_results.include?(pf_result)
    end
    pf_results.each do |pf_result|
      pf_results.delete(pf_result) if !cur_pf_results.include?(pf_result)
    end
    save
  end

end
