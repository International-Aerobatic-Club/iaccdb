class RegionalPilot < ApplicationRecord
  has_many :region_contest
  has_many :pc_results, through: :region_contest
  belongs_to :pilot, class_name: 'Member'
  belongs_to :category

  def self.find_or_create_given_result(year, region, category_id, pilot_id)
    RegionalPilot.where(pilot_id: pilot_id, 
        category_id: category_id,
        region: region,
        year: year).first ||
    RegionalPilot.create(pilot_id: pilot_id, 
        category_id: category_id,
        region: region,
        year: year)
  end

  def to_s
    "#{pilot.name} #{category.name} #{region} #{year}"
  end
end
