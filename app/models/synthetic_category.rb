class SyntheticCategory < ApplicationRecord
  belongs_to :contest
  belongs_to :regular_category, class_name: 'Category'
  serialize :regular_category_flights
  serialize :synthetic_category_flights
end
