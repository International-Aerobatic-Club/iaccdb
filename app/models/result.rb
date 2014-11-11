class Result < ActiveRecord::Base
  attr_accessible :category_id, :name, :pilot_id, :points, :points_possible, :qualified, :rank, :region, :type, :year, :members_attributes
  has_many :result_members
  has_many :members, :through => :result_members
  has_many :result_accums
  has_many :pc_results, :through => :result_accums
  belongs_to :pilot, :class_name => 'Member'
  belongs_to :category

  accepts_nested_attributes_for :members, :allow_destroy => true

  def result_percent
    points_possible && points ? points * 100.0 / points_possible : 0.0
  end
end
