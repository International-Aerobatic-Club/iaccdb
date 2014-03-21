class DataPost < ActiveRecord::Base
  belongs_to :contest

  def to_s
    "data post id #{id} for contest id #{contest_id}"
  end
end
