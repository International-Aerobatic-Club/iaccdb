class FreeProgramK < ApplicationRecord

  belongs_to :category

  validates :year, numericality: { only_integer: true, greater_than: 2005 }
  validates :category_id, uniqueness: { scope: :year, message: "already has a max K factor for that year" }
  validates_presence_of :category_id
  validates :max_k, numericality: { only_integer: true, greater_than: 0 }

end
