FactoryBot.define do
  factory :synthetic_category do
    transient do
      regular_category_name { 'Advanced' }
      regular_category_aircat { 'P' }
      flight_names { ['Known', 'Free', 'Unknown I'] }
      extra_flight_names { ['Unknown II'] }
    end
    initialize_with do
      contest = create(:contest)
      regular_category = create(:category,
        category: regular_category_name, aircat: regular_category_aircat)
      syncat = SyntheticCategory.new(contest: contest,
        regular_category: regular_category)
      syncat.regular_category_flights = flight_names
      syncat.synthetic_category_name =
        [regular_category_name, 'team'].join(' ')
      syncat.synthetic_category_description =
        [regular_category_name, 'team'].join(' ').camelcase
      syncat.synthetic_category_flights = flight_names + extra_flight_names
      syncat
    end
  end
end
