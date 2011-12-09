require 'iac/saComputer'

class PilotFlight < ActiveRecord::Base
  belongs_to :flight
  belongs_to :pilot, :class_name => 'Member'
  has_many :scores, :dependent => :destroy
  belongs_to :sequence
  has_many :pf_results, :dependent => :destroy
  has_many :pfj_results, :dependent => :destroy

  def display
    "Flight #{flight.display} for pilot #{pilot.display}"
  end

  def mark_for_calcs
    pf_results.each do |pf_result|
      pf_result.mark_for_calcs
    end
    pfj_results.each do |pfj_result|
      pfj_result.mark_for_calcs
    end
  end

  # compute or retrieve cached results
  # returns PfResult ActiveRecord instance for this pilot for this flight
  def results
    sac = IAC::SAComputer.new(self)
    sac.computePilotFlight
  end
end
