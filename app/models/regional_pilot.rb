class RegionalPilot < ActiveRecord::Base
  has_many :region_contest
  has_many :pc_results, :through => :region_contest
  belongs_to :pilot, :class_name => 'Member'

  def self.find_or_create_given_pc_result(pc_result)
    RegionalPilot.where(pilot_id: pc_result.pilot, 
        category_id: pc_result.category,
        region: pc_result.region,
        year: pc_result.year).first ||
    RegionalPilot.create(pilot_id: pc_result.pilot,
        category_id: pc_result.category,
        region: pc_result.region,
        year: pc_result.year)
  end
end
