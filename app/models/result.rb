class Result < ActiveRecord::Base
  attr_accessible :category_id, :name, :pilot_id, :points, :points_possible, :qualified, :rank, :region, :type, :year
  has_many :result_members
  has_many :members, :through => :result_members
  has_many :result_accums
  has_many :pc_results, :through => :result_accums
  belongs_to :pilot, :class_name => 'Member'
  belongs_to :category
end
