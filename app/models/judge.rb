class Judge < ActiveRecord::Base
  belongs_to :judge, :class_name => 'Member'
  belongs_to :assist, :class_name => 'Member'
  has_many :scores, :dependent => :destroy

  def to_s
    "Judge #{judge.to_s} " +
    (assist ? "assisted by #{assist.to_s}" : 'without an assistant.')
  end

  def judge_name
    judge ? judge.name : 'missing judge'
  end

  def assistant_name
    assist ? assist.name : 'no assistant'
  end

end
