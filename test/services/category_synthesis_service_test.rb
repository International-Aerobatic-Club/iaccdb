require 'test_helper'

class CategorySynthesisServiceTest < ActiveSupport::TestCase
  setup do
    @synthetic_cat = create(:synthetic_category)
    pilots = create_list(:member, 6)
    judges = create_list(:judge, 4)
    flights = @synthetic_cat.synthetic_category_flights.collect do |name|
      flight = create(:flight,
        name: name,
        contest_id: @synthetic_cat.contest_id,
        category_id: @synthetic_cat.regular_category_id
      )
      pilots.each do |pilot|
        pf = create(:pilot_flight, pilot: pilot, flight: flight)
        judges.each do |judge|
          create(:score, pilot_flight: pf, judge: judge)
        end
      end
      flight
    end
    css = CategorySynthesisService.new(@synthetic_cat)
    css.synthesize_category
  end

  test 'copies flights to synthetic category' do
    cat = @synthetic_cat.find_or_create
    flights = Flight.where(
      contest: @synthetic_cat.contest,
      category: cat
    )
    flight_names = flights.collect(&:name).sort
    assert_equal(flight_names, @synthetic_cat.synthetic_category_flights.sort)
  end

  test 'removes non-regular category flights' do
    cat = @synthetic_cat.regular_category
    flights = Flight.where(
      contest: @synthetic_cat.contest,
      category: cat
    )
    flight_names = flights.collect(&:name).sort
    assert_equal(flight_names, @synthetic_cat.regular_category_flights.sort)
  end
end
