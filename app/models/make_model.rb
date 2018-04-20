class MakeModel < ActiveRecord::Base
  has_many :airplanes, :dependent => :nullify
  validates_uniqueness_of :model, :scope => :make
end
