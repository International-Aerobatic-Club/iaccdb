class ResultMember < ApplicationRecord
  belongs_to :member
  belongs_to :result

  def to_s
    "M2M Result #{result.id} to Member #{member.id}"
  end
end
