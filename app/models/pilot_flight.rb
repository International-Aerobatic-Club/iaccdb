class PilotFlight < ApplicationRecord
  include HorsConcours

  belongs_to :flight
  belongs_to :pilot, :class_name => 'Member'
  has_many :scores, :dependent => :destroy
  belongs_to :sequence, optional: true
  belongs_to :airplane, optional: true
  has_many :pf_results, :dependent => :destroy
  has_many :pfj_results, :dependent => :destroy
  has_one :contest, :through => :flight
  has_one :category, :through => :flight

  def to_s
    a = "Pilot_flight #{id} #{flight} for pilot #{pilot}"
    a += " hors concours" if hors_concours?
    a += "\npf_results [#{pf_results.join("\n\t")}]" if pf_results
    a += "\npfj_results [#{pfj_results.join("\n\t")}]" if pfj_results
  end
end
