# It is unfortunate that: 
#   some models have judge_id referring to a member record with the judge role
#   other models have judge_id referring to one of these
# These are judge teams consisting of:
#   a member referenced as judge in the judge role
#   a member referenced as assist in the assistant role
# Someday rename this model to JudgeTeam and update references
#   to these accordingly.  Ah.  That would be so much better.
class Judge < ActiveRecord::Base
  belongs_to :judge, :class_name => 'Member'
  belongs_to :assist, :class_name => 'Member'
  has_many :scores, :dependent => :nullify
  has_many :pilot_flights, :through => :scores
  has_many :pfj_results, :dependent => :destroy
  has_many :jf_results, :dependent => :destroy

  # supply a standard place-holder instance when needed
  def self.missing_judge
    missing_member = Member.missing_member
    missing_judge = Judge.where(judge_id: missing_member.id, assist_id: nil).first
    if (missing_judge == nil)
      missing_judge = Judge.create(judge_id: missing_member.id, assist_id: nil)
    end
    missing_judge
  end

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
