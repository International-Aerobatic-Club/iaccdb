require 'iac/rank_computer.rb'

class Contest < ActiveRecord::Base
  has_many :flights, :dependent => :destroy
  has_many :c_results, :dependent => :destroy
  has_one :manny_synch, :dependent => :nullify

  def to_s
    "#{name} on #{start.strftime('%b %d, %Y')}"
  end

  def place
    "#{city}, #{state} (#{region})"
  end

  def year_name
    "#{start.year} #{sobriquet}"
  end

  def sobriquet
    if !name.empty?
      name
    else
      id
    end
  end

  # compute all of the flights and the contest rollups
  def results
    compute_flights
    compute_contest_rollups
  end

  # compute results for all flights of the contest
  def compute_flights
    flights.each do |flight|
      flight.compute_flight_results
    end
  end

  # ensure contest rollup computations for this contest are complete
  # return array of category results
  def compute_contest_rollups
    cur_results = Set.new
    flights.each do |flight|
      cur_results.add c_result_for_flight(flight)
    end
    # all cur_results are now either present or added to c_results
    c_results.each do |c_result|
      if (cur_results.include?(c_result))
        c_result.compute_category_totals_and_rankings
      else
        # flights for this category no longer present
        c_results.delete(c_result)
      end
    end
    save
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
    if !c_result
      c_result = c_results.build(:category => flight.category, 
        :aircat => flight.aircat)
      save
    end
    c_result
  end

end

