class Flight < ActiveRecord::Base
  belongs_to :contest, :foreign_key => "contest_id"
  belongs_to :participant, :foreign_key => "chief_id"
  belongs_to :participant, :foreign_key => "assist_id"
end
