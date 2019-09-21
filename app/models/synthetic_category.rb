class SyntheticCategory < ApplicationRecord
  belongs_to :contest
  belongs_to :regular_category, class_name: 'Category'
  serialize :regular_category_flights
  serialize :synthetic_category_flights

  def find_or_create
    last_seq = Category.pluck(:sequence).max
    begin
      cat = Category.find_or_create_by(
        category: self.synthetic_category_name,
        aircat: regular_category.aircat,
      ) do |c|
        c.sequence = last_seq + 1
        c.name = self.synthetic_category_description
        c.synthetic = true
      end
    rescue ActiveRecord::RecordNotUnique
      retry
    end
  end
end
