class Failure < ActiveRecord::Base
  belongs_to :contest
  #manny_id is not an id from MannySynch.  It is the manny system id.
end
