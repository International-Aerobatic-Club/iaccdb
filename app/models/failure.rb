class Failure < ActiveRecord::Base
  attr_accessible :step, :contest_id, :manny_id, :description, :data_post_id

  belongs_to :contest
  #manny_id is not an id from MannySynch.  It is the manny system id.
  belongs_to :data_post
end
