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

  def category
    c_result.category
  end

  def year
    c_result.year
  end

  def region
    c_result.region
  end

  def contest
    c_result.contest
  end

  def pct_possible
    category_value * 100.0 / total_possible
  end

end
