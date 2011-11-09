class PfResult < ActiveRecord::Base
  belongs_to :pilot_flight

#  def find_or_create_by_pilot_flight(pilot_flight)
#    pf = PfResult.where(:pilot_flight => pilot_flight).first
#    if !pf
#      pf = PfResult.new(:pilot_flight => pilot_flight)
#    end
#    pf
#  end
end
