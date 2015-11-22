class PcResult < ActiveRecord::Base
  attr_protected :id

  belongs_to :pilot, :class_name => 'Member'
  belongs_to :c_result
  belongs_to :contest
  belongs_to :category
  has_many :region_contests
  has_many :regional_pilots, :through => :region_contests
  has_many :result_accums
  has_many :results, :through => :result_accums

  def to_s 
    a = "pc_result for pilot #{pilot} value #{category_value}"
  end

  def year
    contest.year
  end

  def region
    contest.region
  end

  def pct_possible
    category_value * 100.0 / total_possible
  end

end
