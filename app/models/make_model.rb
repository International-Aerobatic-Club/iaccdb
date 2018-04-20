class MakeModel < ActiveRecord::Base
  has_many :airplanes, :dependent => :nullify
  validates_uniqueness_of :make, :model
end
