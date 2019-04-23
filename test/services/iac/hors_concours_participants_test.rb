require 'test_helper'

module IAC
  class HorsConcoursParticipantsTest < ActiveSupport::TestCase
    def create_pilot_flights(flight, pilots)
      sequence = create(:sequence)
      pilots.collect do |pilot|
        create(:pilot_flight, pilot: pilot, flight: flight, sequence: sequence)
      end
    end

    setup do
      @lower_cat = Category.find_by(aircat: 'P', category: 'sportsman')
      @higher_cat = Category.find_by(aircat: 'P', category: 'advanced')
      @glider_cat = Category.find_by(aircat: 'G', category: 'sportsman')
      @solo_cat = Category.find_by(aircat: 'P', category: 'unlimited')
      @contest = create(:contest)
      @pilots = create_list(:member, 7)

      known_flight = create(:flight, contest: @contest, category: @higher_cat)
      @known_flights = create_pilot_flights(known_flight, @pilots)

      unknown_flight = create(:flight,
        name: 'Unknown',
        contest: @contest,
        category: @higher_cat)
      unknown_sequence = create(:sequence)
      @unknown_flights = create_pilot_flights(unknown_flight, @pilots)

      @hc = HorsConcoursParticipants.new(@contest)
    end

    test 'does not mark non-solo, non-lower-category' do
      @hc.mark_lower_category_participants_as_hc
      @hc.mark_solo_participants_as_hc
      (@known_flights + @unknown_flights).each do |flight|
        refute(flight.hors_concours?)
        assert_equal(0, flight.hors_concours)
      end
    end

    test 'marks solo participant pilot_flight' do
      known_flight = create(:flight, contest: @contest, category: @solo_cat)
      pf = create(:pilot_flight, flight: known_flight)

      @hc.mark_solo_participants_as_hc
      pf.reload
      assert(pf.hors_concours?)
      assert_equal(HorsConcours::HC_NO_COMPETITION, pf.hors_concours)
    end

    test 'marks lower category participant pilot_flight' do
      pilot = @pilots.first
      known_flight = create(:flight, contest: @contest, category: @lower_cat)
      pf = create(:pilot_flight, pilot: pilot, flight: known_flight)

      @hc.mark_lower_category_participants_as_hc
      pf.reload
      assert(pf.hors_concours?)
      assert_equal(HorsConcours::HC_HIGHER_CATEGORY, pf.hors_concours)
    end

    test 'does not mark lower category pilot_flight in different class' do
      pilot = @pilots.first
      known_flight = create(:flight, contest: @contest, category: @glider_cat)
      pf = create(:pilot_flight, flight: known_flight)

      @hc.mark_lower_category_participants_as_hc
      refute(pf.hors_concours?)
      assert_equal(HorsConcours::HC_FALSE, pf.hors_concours)
    end

    test 'marks pc_result according to pilot_flights' do
      nc_results = @pilots.collect do |pilot|
        create(:pc_result,
          pilot: pilot, contest: @contest, category: @higher_cat)
      end

      pilot = @pilots.first
      known_flight = create(:flight, contest: @contest, category: @lower_cat)
      create_list(:pilot_flight, 3, flight: known_flight)
      pf = create(:pilot_flight, pilot: pilot, flight: known_flight)
      lc_result = create(:pc_result,
        pilot: pilot, contest: @contest, category: @lower_cat)

      known_flight = create(:flight, contest: @contest, category: @solo_cat)
      pf = create(:pilot_flight, flight: known_flight)
      sc_result = create(:pc_result,
        pilot: pf.pilot, contest: @contest, category: @solo_cat)

      @hc.mark_lower_category_participants_as_hc
      @hc.mark_solo_participants_as_hc
      @hc.mark_pc_results_based_on_flights

      nc_results.each do |pcr|
        refute(pcr.reload.hors_concours?)
        assert_equal(HorsConcours::HC_FALSE, pcr.hors_concours);
      end
      assert(lc_result.reload.hors_concours?)
      assert(sc_result.reload.hors_concours?)
    end
  end
end
