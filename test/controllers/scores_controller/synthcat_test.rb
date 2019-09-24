require 'test_helper'
require 'shared/basic_contest_data'

class ScoresController::SynthcatTest < ActionController::TestCase
  include BasicContestData

  setup do
    setup_basic_contest_data
    cat = @flights.first.categories.first
    names = @flights.collect(&:name)
    synth_cat_name = "Synthetic Category for #{cat.category.capitalize}"
    sc = SyntheticCategory.create(
      contest: @contest, regular_category: cat,
      synthetic_category_description: synth_cat_name,
      regular_category_flights: names[0...-1],
      synthetic_category_flights: names)
    CategorySynthesisService.synthesize_categories(@contest)
    @flights.each(&:reload)
    cc = ContestComputer.new(@contest)
    cc.compute_results
  end

  test 'contains the flights only once' do
    pilot = @pilots.first
    get :show, params: { pilot_id: pilot.id, id: @contest.id }
    @flights.each do |flight|
      assert_select(
        "div.flightScores h3 a[href='#{flight_path(flight.id)}']", 1)
      assert_select('div.flightScores h3 a', flight.displayName)
    end
  end
end
