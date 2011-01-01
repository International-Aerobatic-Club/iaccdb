class Flight < ActiveRecord::Base
  belongs_to :contest, :foreign_key => "contest_id"
  belongs_to :chief, :foreign_key => "chief_id", :class_name => 'Member'
  belongs_to :assist, :foreign_key => "assist_id", :class_name => 'Member'
end
