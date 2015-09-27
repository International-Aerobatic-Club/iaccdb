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

  # update pc_results such that it contains only to_be_results
  # by keeping those that already are, deleting those that are no longer,
  # and adding those that are not
  # to_be_results is an array of pc_result
  # return self
  def update_results(to_be_results)
    existing_results = self.pc_results.all
    to_remove = existing_results - to_be_results
    to_add = to_be_results - existing_results
    to_remove.each { |pc_result| self.pc_results.delete(pc_result) }
    to_add.each { |pc_result| self.pc_results.push(pc_result) }
    self
  end

  def add_member_if_not_present(member)
    unless result_members.where(:member => member.id).first
      members << member
    end
  end

end
