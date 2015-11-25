class PcResult < ActiveRecord::Base
  attr_protected :id

  belongs_to :pilot, :class_name => 'Member'
  belongs_to :c_result
  belongs_to :contest
  belongs_to :category
  has_many :region_contests
  has_many :regional_pilots, :through => :region_contests
  has_many :result_accums
  has_many :results, :through => :result_accums

  def to_s 
    a = "pc_result for pilot #{pilot} value #{category_value}"
  end

  def year
    contest.year
  end

  def region
    contest.region
  end

  def pct_possible
    category_value * 100.0 / total_possible
  end

  def compute_category_totals
    category_value = 0.0
    total_possible = 0
    flights = contest.flights.where(category: category)
    flights.each do |flight|
      pf_results = PfResult.joins(:pilot_flight).where(
        { pilot_flights: {pilot_id: pilot, flight_id: flight}})
      pf_results.each do |pf_result|
        category_value += pf_result.adj_flight_value
        total_possible += pf_result.total_possible
      end
    end
    save
  end
end
