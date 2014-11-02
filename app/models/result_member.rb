class ResultMember < ActiveRecord::Base
  attr_accessible :member_id, :result_id
  belongs_to :member
  belongs_to :result
end
