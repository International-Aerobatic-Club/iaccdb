class Chief < ApplicationRecord

  belongs_to :chief, class_name: 'Member'
  has_many :flights

  def to_s
    "Judge #{id} #{judge.to_s}"
  end

  def team_name
    chief.name || 'missing chief judge name'
  end

end
