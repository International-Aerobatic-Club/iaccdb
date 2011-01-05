class PilotFlight < ActiveRecord::Base
  belongs_to :flight
  belongs_to :pilot, :class_name => 'Member'
  has_many :scores, :dependent => :destroy

  def display
    "Flight #{flight.display} for pilot #{pilot.display}"
  end
end
