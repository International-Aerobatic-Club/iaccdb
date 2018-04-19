class AirplaneModel < ActiveRecord::Base
  validates_uniqueness_of :make, :model
end
