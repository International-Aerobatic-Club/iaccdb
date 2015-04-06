# It is unfortunate that: 
#   some models have judge_id referring to a member record with the judge role
#   other models have judge_id referring to one of these
# These are judge teams consisting of:
#   a member referenced as judge in the judge role
#   a member referenced as assist in the assistant role
# Someday rename this model to JudgeTeam and update references
#   to these accordingly.  Ah.  That would be so much better.
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

  # let all records referencing this judge/assistant pair
  # reference instead a judge/assistant pair with 
  #   judge j_id and self.assist_id
  # does nothing if j_id is the same as self.judge_id
  def merge_judge(j_id)
    if (j_id != judge_id)
      new_judge = Judge.where(:judge_id => j_id, :assist_id => assist_id).first
      unless new_judge
        new_judge = Judge.create(:judge_id => j_id, :assist_id => assist_id)
      end
      replace_with_judge_pair(new_judge)
    end
  end

  # let all records referencing this judge/assistant pair
  # reference instead a judge/assistant pair with 
  #   assistant a_id and self.judge_id
  # does nothing if a_id is the same as self.assist_id
  def merge_assist(a_id)
    if (a_id != assist_id)
      new_judge = Judge.where(:judge_id => judge_id, :assist_id => a_id).first
      unless new_judge
        new_judge = Judge.create(:judge_id => judge_id, :assist_id => a_id)
      end
      replace_with_judge_pair(new_judge)
    end
  end

  #######
  private
  #######
  
  def replace_with_judge_pair(new_judge)
    Score.where('judge_id = ?', id).update_all(judge_id: new_judge.id)
    PfjResult.where('judge_id = ?', id).update_all(judge_id: new_judge.id)
    JfResult.where('judge_id = ?', id).update_all(judge_id: new_judge.id)
  end

end
