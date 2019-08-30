class MakeModel < ApplicationRecord
  has_many :airplanes, :dependent => :nullify
  validates_uniqueness_of :model, :scope => :make

  def self.all_by_make
    MakeModel.order(:make, :model).all.to_a.group_by(&:make)
  end
end
