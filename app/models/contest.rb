require 'iac/rank_computer.rb'

class Contest < ActiveRecord::Base
  has_many :flights, :dependent => :destroy
  has_many :c_results, :dependent => :destroy

  def to_s
    "#{name} on #{start.strftime('%b %d, %Y')}"
  end

  def place
    "#{city}, #{state} (#{region})"
  end

  def sobriquet
    if !name.empty?
      name
    else
      id
    end
  end

  def mark_for_calcs(flight)
    c_result_for_flight(flight).mark_for_calcs
  end

  # ensure all computations for this contest are complete
  # return array of category results
  def results
    cur_results = []
    flights.each do |flight|
      pf_results = flight.results
      cur_results << c_result_for_flight(flight)
    end
    c_results.each do |c_result|
      if (cur_results.include?(c_result))
        c_result.compute_category_totals_and_rankings
      else
        c_result.delete
      end
    end
    c_results
  end

###
private
###
  # creates c_result for category of flight if it doesn't exist
  # returns the c_result
  def c_result_for_flight(flight)
    c_result = c_results.first(:conditions => {
      :category => flight.category, :aircat => flight.aircat})
    c_result = CResult.create(:contest => self, 
      :category => flight.category, :aircat => flight.aircat) if !c_result
  end
end

