class Judge < ActiveRecord::Base
  attr_protected :id

  belongs_to :judge, :class_name => 'Member'
  belongs_to :assist, :class_name => 'Member'
  has_many :scores, :dependent => :destroy
  has_many :pilot_flights, :through => :scores
  has_many :pfj_results, :dependent => :destroy
  has_many :jf_results, :dependent => :destroy
  
  def to_s
    "Judge #{id} #{judge.to_s} " +
    (assist ? "assisted by #{assist.to_s}" : '')
  end

  def team_name
    "#{judge_name} " +
    (assist ? "assisted by #{assist.name}" : '')
  end

  def judge_name
    judge ? judge.name : 'missing judge'
  end

  def assistant_name
    assist ? assist.name : 'no assistant'
  end

end
