class PcResult < ApplicationRecord
  include HorsConcours

  belongs_to :pilot, :class_name => 'Member'
  belongs_to :contest
  belongs_to :category
  has_many :region_contests
  has_many :regional_pilots, :through => :region_contests
  has_many :result_accums
  has_many :results, :through => :result_accums

  def to_s
    a = "pc_result #{id} for pilot #{pilot} value #{category_value}"
    a += " (HC #{hors_concours})" if hors_concours?
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

  def is_five_cat
    ['P','G'].include? category.aircat
  end

  def compute_category_totals
    self.category_value = 0.0
    self.total_possible = 0
    flights = category.flights.where(contest: contest)
    flights.each do |flight|
      pf_results = PfResult.joins(:pilot_flight).where(
        { pilot_flights: {pilot_id: pilot, flight_id: flight}})
      pf_results.each do |pf_result|
        self.category_value += pf_result.adj_flight_value
        self.total_possible += pf_result.total_possible
        self.hors_concours |= pf_result.hors_concours
      end
    end
    save!
  end
end
