class RegionContest < ActiveRecord::Base
  attr_protected :id

  belongs_to :pc_result
  belongs_to :regional_pilot
end
