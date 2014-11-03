class ResultAccum < ActiveRecord::Base
  attr_accessible :pc_result_id, :result_id
  belongs_to :pc_result
  belongs_to :result
end
