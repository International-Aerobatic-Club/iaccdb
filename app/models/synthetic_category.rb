class SyntheticCategory < ApplicationRecord
  belongs_to :contest
  belongs_to :regular_category, class_name: 'Category'
  serialize :regular_category_flights
  serialize :synthetic_category_flights

  def find_or_create
    last_seq = Category.maximum(:sequence)
    begin
      cat = Category.find_or_create_by(
        category: regular_category.category,
        aircat: regular_category.aircat,
        name: self.synthetic_category_description
      ) do |c|
        c.sequence = last_seq + 1
        c.synthetic = true
      end
    rescue ActiveRecord::RecordNotUnique
      retry
    end
  end
end
