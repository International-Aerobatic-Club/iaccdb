require 'test_helper'

class CategorySynthesisServiceTest < ActiveSupport::TestCase
  def setup_synthetic_category(contest, reg_cat)
    synth_cat = create(
      :synthetic_category,
      contest: contest,
      regular_category_name: reg_cat.category,
      regular_category_aircat: reg_cat.aircat
    )
    pilots = create_list(:member, 6)
    judges = create_list(:judge, 4)
    flights = synth_cat.synthetic_category_flights.collect do |name|
      flight = create(:flight,
        name: name,
        contest_id: synth_cat.contest_id,
        category_id: synth_cat.regular_category_id
      )
      pilots.each do |pilot|
        pf = create(:pilot_flight, pilot: pilot, flight: flight)
        judges.each do |judge|
          create(:score, pilot_flight: pf, judge: judge)
        end
      end
      flight
    end
    synth_cat
  end

  def collect_flight_names(contest, cat)
    flights = cat.flights.where(contest: contest)
    flights.collect(&:name).sort
  end

  setup do
    @contest = create(:contest)
    reg_cat = create(:category, category: 'Advanced', aircat: 'P')
    @synthetic_cat = setup_synthetic_category(@contest, reg_cat)
  end

  test 'copies flights to synthetic category' do
    CategorySynthesisService.synthesize_category(@synthetic_cat)
    cat = @synthetic_cat.find_or_create
    flight_names = collect_flight_names(@contest, cat)
    assert_equal(flight_names, @synthetic_cat.synthetic_category_flights.sort)
  end

  test 'removes non-regular category flights' do
    CategorySynthesisService.synthesize_category(@synthetic_cat)
    cat = @synthetic_cat.regular_category
    flight_names = collect_flight_names(@contest, cat)
    assert_equal(flight_names, @synthetic_cat.regular_category_flights.sort)
  end

  test 'processes synthetic categories for a contest' do
    reg_cat = create(:category, category: 'Unlimited', aircat: 'P')
    synth_cat_unl = setup_synthetic_category(@contest, reg_cat)
    CategorySynthesisService.synthesize_categories(@contest)

    cat = @synthetic_cat.find_or_create
    flight_names = collect_flight_names(@contest, cat)
    assert_equal(flight_names, @synthetic_cat.synthetic_category_flights.sort)

    cat = synth_cat_unl.find_or_create
    flight_names = collect_flight_names(@contest, cat)
    assert_equal(flight_names, @synthetic_cat.synthetic_category_flights.sort)
  end
end
