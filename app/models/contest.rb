require 'iac/rank_computer.rb'

class Contest < ActiveRecord::Base
  attr_accessible :name, :city, :state, :start, :chapter, :director, :region

  has_many :flights, :dependent => :destroy
  has_many :jc_results, :dependent => :destroy
  has_many :pc_results, :dependent => :destroy

  has_one :manny_synch, :dependent => :nullify
  has_many :data_posts, :dependent => :nullify
  has_many :failures, :dependent => :destroy

  validates :name, :length => { :in => 4..48 }
  validates :city, :length => { :maximum => 24 }
  validates :state, :length => { :maximum => 2 }
  validates :director, :length => { :maximum => 48 }
  validates :region, :length => { :maximum => 16 }

  def to_s
    "#{name} on #{start.strftime('%b %d, %Y')}"
  end

  def place
    "#{city}, #{state} (#{region})"
  end

  def year_name
    "#{start.year} #{sobriquet}"
  end

  def year
    start.year if start
  end

  def year=(yyyy)
    self.start = Time.mktime(yyyy)
  end

  def sobriquet
    if name && !name.empty?
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
      flight.compute_flight_results(2014 <= year)
    end
  end

  # ensure contest rollup computations for this contest are complete
  # return array of category results
  def compute_contest_rollups
    cur_results = Set.new
    cats = flights.collect { |f| f.category }
    cats = cats.uniq
    # all cur_results are now either present or added to c_results
    cats.each do |cat|
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

  # remove all contest associated data except the base 
  # attributes.  Keep association with manny_synch
  def reset_to_base_attributes
    flights.clear
    c_results.clear
    failures.clear
  end

end

