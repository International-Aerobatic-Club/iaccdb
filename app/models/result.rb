class Result < ApplicationRecord
  has_many :result_members
  has_many :members, :through => :result_members
  has_many :result_accums
  has_many :pc_results, :through => :result_accums
  belongs_to :pilot, :class_name => 'Member', optional: true
  belongs_to :category, optional: true

  accepts_nested_attributes_for :members, :allow_destroy => true

  def result_percent
    points_possible && points ? points * 100.0 / points_possible : 0.0
  end

  # update pc_results such that it contains only to_be_results
  # by keeping those that already are, deleting those that are no longer,
  # and adding those that are not
  # to_be_results is an array of pc_result
  # do not save
  # return self
  def update_results(to_be_results)
    existing_results = self.pc_results.to_a
    to_remove = existing_results - to_be_results
    to_add = to_be_results - existing_results
    if (0 < to_remove.count)
      self.pc_results.delete(to_remove)
    end
    if (0 < to_add.count)
      self.pc_results.push(to_add)
    end
    self
  end

  def add_member_if_not_present(member)
    unless result_members.where(:member => member.id).first
      members << member
    end
  end

end
