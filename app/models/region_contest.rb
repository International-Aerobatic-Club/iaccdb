class RegionContest < ActiveRecord::Base
  belongs_to :pc_result
  belongs_to :regional_pilot
end
